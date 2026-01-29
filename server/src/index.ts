import { createApp } from './app';

const port = Number(process.env.PORT ?? 37123);

const app = createApp();

app.listen(port, () => {
  console.log(`BFF 服务已启动，端口 ${port}`);
});
