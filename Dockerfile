# 第一阶段：构建阶段
FROM node:18.18 AS build

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 安装依赖
RUN npm install

# 构建项目
RUN npm run build

# 第二阶段：生产阶段
FROM flashspys/nginx-static

# 将构建阶段生成的静态文件复制到 Nginx 的默认网站目录
COPY --from=build /app/dist /static

# 暴露端口
EXPOSE 80
