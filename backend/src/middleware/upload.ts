import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { Request } from 'express';
import { AppError } from './errorHandler';

// Ensure uploads directory exists
const uploadsDir = process.env.UPLOAD_DIR || './uploads';
const foodImagesDir = path.join(uploadsDir, 'food-images');

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

if (!fs.existsSync(foodImagesDir)) {
  fs.mkdirSync(foodImagesDir, { recursive: true });
}

// Configure multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, foodImagesDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename: timestamp-userId-originalname
    const userId = (req as any).user?.id || 'anonymous';
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    const basename = path.basename(file.originalname, ext).toLowerCase().replace(/[^a-z0-9]/g, '-');
    const filename = `${timestamp}-${userId}-${basename}${ext}`;
    cb(null, filename);
  },
});

// File filter
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  // Check if file is an image
  if (!file.mimetype.startsWith('image/')) {
    cb(new AppError('Only image files are allowed', 400));
    return;
  }

  // Allowed image types
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/webp'
  ];

  if (!allowedMimeTypes.includes(file.mimetype)) {
    cb(new AppError('Invalid image format. Only JPEG, PNG, and WebP are allowed', 400));
    return;
  }

  cb(null, true);
};

// Configure multer
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE || '5242880'), // 5MB default
    files: 1, // Single file upload
  },
});

// Middleware for single food image upload
export const uploadFoodImage = upload.single('image');

// Error handling middleware for multer
export const handleUploadError = (error: any, req: Request, res: any, next: any) => {
  if (error instanceof multer.MulterError) {
    switch (error.code) {
      case 'LIMIT_FILE_SIZE':
        return next(new AppError('File size too large. Maximum size is 5MB', 413));
      case 'LIMIT_FILE_COUNT':
        return next(new AppError('Too many files. Only one file is allowed', 400));
      case 'LIMIT_UNEXPECTED_FILE':
        return next(new AppError('Unexpected field name. Use "image" as the field name', 400));
      default:
        return next(new AppError(`Upload error: ${error.message}`, 400));
    }
  }
  next(error);
};

// Utility function to delete uploaded file
export const deleteFile = (filePath: string): Promise<void> => {
  return new Promise((resolve, reject) => {
    fs.unlink(filePath, (err) => {
      if (err && err.code !== 'ENOENT') {
        reject(err);
      } else {
        resolve();
      }
    });
  });
};

// Utility function to get file URL
export const getFileUrl = (filename: string): string => {
  if (process.env.NODE_ENV === 'production') {
    // In production, you might use a CDN or different base URL
    return `${process.env.BASE_URL || 'https://api.yourapp.com'}/uploads/food-images/${filename}`;
  } else {
    return `http://localhost:${process.env.PORT || 3000}/uploads/food-images/${filename}`;
  }
};