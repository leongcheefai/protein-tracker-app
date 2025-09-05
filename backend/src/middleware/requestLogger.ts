import { Request, Response, NextFunction } from 'express';

export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  const start = Date.now();
  
  // Log request
  const logRequest = () => {
    const duration = Date.now() - start;
    const timestamp = new Date().toISOString();
    
    console.log(`[${timestamp}] ${req.method} ${req.originalUrl} - ${res.statusCode} - ${duration}ms`);
    
    if (process.env.NODE_ENV === 'development') {
      if (req.body && Object.keys(req.body).length > 0) {
        console.log('Request Body:', JSON.stringify(req.body, null, 2));
      }
      if (req.query && Object.keys(req.query).length > 0) {
        console.log('Query Params:', JSON.stringify(req.query, null, 2));
      }
    }
  };

  // Listen for response finish to log
  res.on('finish', logRequest);
  res.on('close', logRequest);

  next();
};