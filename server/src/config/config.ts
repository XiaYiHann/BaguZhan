interface Config {
  port: number;
  nodeEnv: string;
  dbPath: string;
  adminApiKey: string;
}

const config: Config = {
  port: parseInt(process.env.PORT || '37123', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  dbPath: process.env.DB_PATH || './database/data.db',
  adminApiKey: process.env.ADMIN_API_KEY || 'baguzhan-admin-secret-2024',
};

export { config };
