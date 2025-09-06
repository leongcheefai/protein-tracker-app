import OpenAI from 'openai';
import sharp from 'sharp';
import fs from 'fs/promises';
import path from 'path';
import { NutritionData, DetectedFood } from '../types/supabase';

export interface FoodRecognitionResult {
  name: string;
  confidence: number;
  category: string;
  nutritionPer100g: NutritionData;
  estimatedPortion?: {
    grams: number;
    description: string;
  };
  boundingBox?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

export class FoodRecognitionService {
  private openai: OpenAI | null = null;
  private isConfigured: boolean = false;

  constructor() {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      console.warn('⚠️  OPENAI_API_KEY not found - food recognition will use fallback mode');
      this.isConfigured = false;
      return;
    }

    this.openai = new OpenAI({
      apiKey: apiKey,
    });
    this.isConfigured = true;
    console.log('✅ OpenAI service initialized successfully');
  }

  /**
   * Process and optimize image for AI analysis
   */
  async processImage(imagePath: string): Promise<string> {
    try {
      // Read and optimize image with Sharp
      const optimizedBuffer = await sharp(imagePath)
        .resize(1024, 1024, { 
          fit: 'inside',
          withoutEnlargement: true 
        })
        .jpeg({ 
          quality: 85,
          progressive: true 
        })
        .toBuffer();

      // Create temp file path for processed image
      const processedPath = imagePath.replace(/\.[^/.]+$/, '_processed.jpg');
      await fs.writeFile(processedPath, optimizedBuffer);

      return processedPath;
    } catch (error) {
      console.error('Error processing image:', error);
      throw new Error('Failed to process image for analysis');
    }
  }

  /**
   * Convert image to base64 for OpenAI API
   */
  async imageToBase64(imagePath: string): Promise<string> {
    try {
      const imageBuffer = await fs.readFile(imagePath);
      return imageBuffer.toString('base64');
    } catch (error) {
      console.error('Error converting image to base64:', error);
      throw new Error('Failed to convert image to base64');
    }
  }

  /**
   * Recognize food items in image using GPT-4 Vision
   */
  async recognizeFoodItems(imagePath: string): Promise<FoodRecognitionResult[]> {
    // If OpenAI is not configured, return mock data
    if (!this.isConfigured || !this.openai) {
      console.log('🔄 Using fallback food detection (OpenAI not configured)');
      return this.getFallbackResults();
    }

    try {
      // Process image first
      const processedImagePath = await this.processImage(imagePath);
      
      // Convert to base64
      const base64Image = await this.imageToBase64(processedImagePath);

      // Prepare the prompt for food recognition
      const prompt = `
        Analyze this food image and identify all visible food items. For each food item, provide:

        1. Food name (be specific, e.g., "Grilled Chicken Breast" not just "Chicken")
        2. Confidence level (0.0 to 1.0)
        3. Food category (protein, vegetable, grain, fruit, dairy, snack, beverage, etc.)
        4. Estimated portion size in grams
        5. Nutritional information per 100g (calories, protein, carbs, fat, fiber, sugar, sodium)

        Return ONLY a valid JSON array with this exact structure:
        [
          {
            "name": "Food Name",
            "confidence": 0.95,
            "category": "protein",
            "estimatedPortion": {
              "grams": 150,
              "description": "1 medium chicken breast"
            },
            "nutritionPer100g": {
              "calories": 165,
              "protein": 31,
              "carbs": 0,
              "fat": 3.6,
              "fiber": 0,
              "sugar": 0,
              "sodium": 74
            }
          }
        ]

        Important:
        - Focus on protein-rich foods but identify all visible food items
        - Be conservative with confidence scores - only use >0.9 for very clear items
        - Provide realistic portion estimates
        - Use standard USDA nutritional values
        - If you see multiple items of the same food, list them separately with individual portions
        - Return empty array [] if no food is clearly visible
      `;

      const response = await this.openai.chat.completions.create({
        model: "gpt-4o", // GPT-4 with vision capabilities
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: prompt
              },
              {
                type: "image_url",
                image_url: {
                  url: `data:image/jpeg;base64,${base64Image}`
                }
              }
            ]
          }
        ],
        max_tokens: 2000,
        temperature: 0.1, // Low temperature for consistent results
      });

      // Parse the response
      const aiResponse = response.choices[0]?.message?.content;
      if (!aiResponse) {
        throw new Error('No response from OpenAI API');
      }

      // Clean up temporary processed image
      try {
        await fs.unlink(processedImagePath);
      } catch (error) {
        console.warn('Failed to clean up processed image:', error);
      }

      // Parse JSON response
      let recognitionResults: FoodRecognitionResult[];
      try {
        // Remove any markdown formatting if present
        const cleanedResponse = aiResponse.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
        recognitionResults = JSON.parse(cleanedResponse);
      } catch (parseError) {
        console.error('Failed to parse AI response:', aiResponse);
        throw new Error('Invalid response format from AI');
      }

      // Validate and sanitize results
      const validatedResults = this.validateResults(recognitionResults);

      console.log(`🎯 Food Recognition: Found ${validatedResults.length} food items`);
      return validatedResults;

    } catch (error) {
      console.error('Error in food recognition:', error);
      throw new Error(`Food recognition failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Validate and sanitize AI recognition results
   */
  private validateResults(results: any[]): FoodRecognitionResult[] {
    if (!Array.isArray(results)) {
      console.warn('AI response is not an array, returning empty results');
      return [];
    }

    return results
      .filter(item => {
        // Basic validation
        return (
          item &&
          typeof item.name === 'string' &&
          typeof item.confidence === 'number' &&
          item.confidence >= 0 &&
          item.confidence <= 1 &&
          item.nutritionPer100g &&
          typeof item.nutritionPer100g.calories === 'number' &&
          typeof item.nutritionPer100g.protein === 'number'
        );
      })
      .map(item => ({
        name: item.name.trim(),
        confidence: Math.min(1, Math.max(0, item.confidence)),
        category: item.category || 'other',
        nutritionPer100g: {
          calories: Math.max(0, item.nutritionPer100g.calories),
          protein: Math.max(0, item.nutritionPer100g.protein),
          carbs: Math.max(0, item.nutritionPer100g.carbs || 0),
          fat: Math.max(0, item.nutritionPer100g.fat || 0),
          fiber: Math.max(0, item.nutritionPer100g.fiber || 0),
          sugar: Math.max(0, item.nutritionPer100g.sugar || 0),
        },
        estimatedPortion: item.estimatedPortion ? {
          grams: Math.max(1, item.estimatedPortion.grams),
          description: item.estimatedPortion.description || `${item.estimatedPortion.grams}g serving`
        } : undefined,
        boundingBox: item.boundingBox || undefined
      }))
      .slice(0, 10); // Limit to 10 items max
  }

  /**
   * Get nutrition information for a specific food item by name
   */
  async getNutritionInfo(foodName: string): Promise<NutritionData | null> {
    try {
      const prompt = `
        Provide accurate nutritional information per 100g for: ${foodName}
        
        Return ONLY a valid JSON object with this exact structure:
        {
          "calories": 165,
          "protein": 31,
          "carbs": 0,
          "fat": 3.6,
          "fiber": 0,
          "sugar": 0
        }
        
        Use standard USDA nutritional database values.
      `;

      const response = await this.openai.chat.completions.create({
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }],
        max_tokens: 200,
        temperature: 0.1,
      });

      const aiResponse = response.choices[0]?.message?.content;
      if (!aiResponse) return null;

      const cleanedResponse = aiResponse.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const nutritionData = JSON.parse(cleanedResponse);

      return {
        calories: Math.max(0, nutritionData.calories),
        protein: Math.max(0, nutritionData.protein),
        carbs: Math.max(0, nutritionData.carbs || 0),
        fat: Math.max(0, nutritionData.fat || 0),
        fiber: Math.max(0, nutritionData.fiber || 0),
        sugar: Math.max(0, nutritionData.sugar || 0),
      };

    } catch (error) {
      console.error('Error getting nutrition info:', error);
      return null;
    }
  }

  /**
   * Fallback food recognition when OpenAI is not available
   */
  private async getFallbackResults(): Promise<FoodRecognitionResult[]> {
    // Simulate processing delay
    await new Promise(resolve => setTimeout(resolve, 1000));

    return [
      {
        name: 'Mixed Food Item',
        confidence: 0.6,
        category: 'mixed',
        nutritionPer100g: {
          calories: 200,
          protein: 15,
          carbs: 20,
          fat: 8,
          fiber: 3,
          sugar: 5,
        },
        estimatedPortion: {
          grams: 150,
          description: 'Medium serving'
        }
      }
    ];
  }
}