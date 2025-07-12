# ToDoAeo项目开发文档

## 项目概述

本项目旨在开发一个简洁易用但功能强大的ToDoList应用，采用前后端分离架构。后端使用Gin框架，前端使用Flutter实现跨平台支持。应用支持内网数据同步和WebDav同步，确保数据不上云，保障用户隐私。

## 界面内容规划

### 1. 登录/注册页面

- **功能**：用户选择本地使用，或者部署服务器，或者使用WebDav
- **组件**：
  - 用户名/输入框
  - 密码输入框
  - 登录按钮
  - 服务器地址配置（用于内网同步）

### 2. 主页面

- **功能**：展示所有任务列表，支持分类查看
- **组件**：
  - 顶部导航栏：包含应用名称、同步按钮、设置按钮
  - 侧边栏：任务分类（全部、今日、待办、已完成、收藏等）
  - 任务列表区域：展示任务卡片
  - 底部浮动按钮：添加新任务

### 3. 任务详情页

- **功能**：查看和编辑任务详细信息
- **组件**：
  - 任务标题
  - 任务描述
  - 截止日期选择器
  - 优先级选择器
  - 标签选择器/添加器
  - 完成状态切换
  - 收藏按钮
  - 删除按钮

### 4. 设置页面

- **功能**：应用设置和账户管理
- **组件**：
  - 账户信息展示
  - 服务器地址配置
  - WebDav配置
  - 同步设置
  - 主题切换
  - 数据备份与恢复

## 路由管理

### 后端路由（Gin框架）

#### 用户管理

```plaint-text
POST /api/users/register - 用户注册
POST /api/users/login - 用户登录
GET /api/users/me - 获取当前用户信息
PUT /api/users/me - 更新当前用户信息
```

#### 任务管理

```plaint-text
GET /api/tasks - 获取所有任务
GET /api/tasks/:id - 获取单个任务
POST /api/tasks - 创建新任务
PUT /api/tasks/:id - 更新任务
DELETE /api/tasks/:id - 删除任务
```

#### 分类管理

```plaint-text
GET /api/categories - 获取所有分类
POST /api/categories - 创建新分类
PUT /api/categories/:id - 更新分类
DELETE /api/categories/:id - 删除分类
```

#### 同步管理

```plaint-text
POST /api/sync/upload - 上传同步数据
POST /api/sync/download - 下载同步数据
```

### 前端路由（Flutter）

```dart
// 路由配置示例
final routes = {
  '/': (context) => HomePage(),
  '/login': (context) => LoginPage(),
  '/task/:id': (context) => TaskDetailPage(),
  '/settings': (context) => SettingsPage(),
  '/webdav-config': (context) => WebDavConfigPage(),
};
```

## 技术栈

### 后端

- 框架：Gin
- 数据库：SQLite（支持扩展到MySQL或PostgreSQL）
- 认证：JWT
- 容器化：Docker

### 前端

- 框架：Flutter
- 状态管理：Provider
- 网络请求：http
- 本地存储：sqflite

## 数据模型

### 任务模型

```go
type Task struct {
    ID          int       `json:"id"`
    Title       string    `json:"title"`
    Description string    `json:"description"`
    DueDate     time.Time `json:"dueDate"`
    Priority    int       `json:"priority"`
    Completed   bool      `json:"completed"`
    Favorite    bool      `json:"favorite"`
    CategoryID  int       `json:"categoryId"`
    CreatedAt   time.Time `json:"createdAt"`
    UpdatedAt   time.Time `json:"finishingAt"`
}
```

### 分类模型

```go
type Category struct {
    ID        int       `json:"id"`
    Name      string    `json:"name"`
    CreatedAt time.Time `json:"createdAt"`
    UpdatedAt time.Time `json:"finishingAt"`
}
```

### 用户模型

```go
type User struct {
    ID        int       `json:"id"`
    Username  string    `json:"username"`
    Email     string    `json:"email"`
    Password  string    `json:"password"`
    CreatedAt time.Time `json:"createdAt"`
    UpdatedAt time.Time `json:"finishingAt"`
}
```

## 部署方案

### 后端部署

1. 构建Docker镜像
2. 配置Docker容器
3. 启动容器并映射端口

### 前端部署

- 移动应用：打包为APK
- 桌面应用：打包成EXE

## 同步机制

### 内网同步

- 使用HTTP API进行数据交换
- 实现冲突检测和解决机制
- 支持增量同步

### WebDav同步

- 集成WebDav客户端库
- 实现数据导出和导入功能
- 支持定期自动同步
