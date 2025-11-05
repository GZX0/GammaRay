# GammaRay Windows CI/CD with QEMU and vcpkg

## 概述

本项目已成功配置了完整的Windows CI/CD流水线，支持使用QEMU进行跨平台编译和vcpkg依赖管理。

## 已创建的文件

### GitHub Actions 工作流
- `.github/workflows/windows-build-simple.yml` - 主要Windows构建工作流
- `.github/workflows/windows-qemu-simple.yml` - QEMU跨平台编译工作流
- `.github/workflows/README.md` - 详细的工作流文档

### 配置文件
- `env_settings.cmake` - 更新的环境配置，支持CI/CD环境变量
- `docker-compose.yml` - Docker Compose配置
- `docker/vcpkg.Dockerfile` - vcpkg依赖安装的Docker镜像

### 脚本工具
- `scripts/local-qemu-build.sh` - 本地QEMU构建脚本
- `scripts/test-ci-config.sh` - CI配置验证脚本

## 主要特性

### 1. 原生Windows构建 (windows-build-simple.yml)
- 使用GitHub Actions Windows runner
- 自动安装和缓存vcpkg依赖
- Qt 6.8.3集成
- MSVC 2022编译器
- 支持Debug和Release配置

### 2. QEMU跨平台编译 (windows-qemu-simple.yml)
- 在Ubuntu runner上使用QEMU模拟Windows
- Docker容器化构建环境
- 多阶段构建优化
- 自动提取构建产物

### 3. 依赖管理
所有vcpkg依赖已预先配置：
```
gflags, sqlite3, detours, gtest, libvpx, opus, fftw3, easyhook, 
glm, sdl2, jemalloc, protobuf, asio, openssl, ffmpeg, opencv, cpr
```

## 使用方法

### 触发构建
1. **自动触发**: 推送到main/develop分支或创建Pull Request
2. **手动触发**: 在GitHub Actions页面手动运行工作流
3. **QEMU构建**: 推送到`ci/windows-qemu-vcpkg-build`分支

### 本地测试
```bash
# 测试QEMU构建
./scripts/local-qemu-build.sh

# 验证配置
./scripts/test-ci-config.sh
```

## 构建产物
- Windows可执行文件和DLL
- 完整的依赖库
- 构建信息和版本号
- 自动上传到GitHub Artifacts

## 环境变量支持
构建系统支持以下环境变量覆盖：
- `VCPKG_ROOT` - vcpkg安装路径
- `QT_ROOT` - Qt安装路径
- `VK_SDK_ROOT` - Vulkan SDK路径

## 性能优化
- vcpkg依赖缓存
- Docker层缓存
- 并行编译支持
- 增量构建

## 故障排除

### 常见问题
1. **vcpkg依赖冲突**: 清理缓存重新安装
2. **Qt路径问题**: 验证版本和架构匹配
3. **QEMU构建失败**: 检查Docker和QEMU配置
4. **内存不足**: 减少并行编译任务数

### 调试步骤
1. 检查工作流日志
2. 验证环境变量
3. 测试本地构建
4. 检查Docker镜像

## 下一步
1. 推送代码到远程仓库
2. 监控GitHub Actions执行
3. 验证构建产物
4. 根据需要调整配置

## 技术栈
- **CI/CD**: GitHub Actions
- **虚拟化**: QEMU + Docker
- **构建系统**: CMake + vcpkg
- **编译器**: MSVC 2022
- **框架**: Qt 6.8.3
- **目标平台**: Windows x64

此配置已准备就绪，可以立即开始使用。