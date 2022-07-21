## 更快地构建 Laravel Sail 容器

## 特性

* 使用国内镜像进行环境下载及安装, 更快地完成容器的构建;
* 自动配置 Composer npm yarn 源为国内镜像; 
* 自动启动并维护 Laravel Octane 进程; 
* 自动启动并维护 Laravel Queue 进程; 
* 自动安装 [XlsWriter](https://github.com/viest/php-ext-xlswriter) 扩展; 

## 使用方法
先发布 Laravel Sail 的 Docker 文件:
```shell
sail artisan sail:publish
```
将使用本仓库的文件覆盖 `docker/8.1` 中的文件, 使用以下命令重新构建容器
```shell
sail build --no-cache
```

## 启用 Laravel Octane

如果要启动 Laravel Octane, 你还需要在项目根目录的 `docker-compose.yml` 文件中映射容器的 8000 端口
```yaml
# For more information: https://laravel.com/docs/sail
version: '3'
services:
    laravel.test:
        ...
        ports:
            - '${APP_PORT:-80}:80'
            - '${HMR_PORT:-8080}:8080'
            - '8000:8000' # 添加此行，将容器的 8000 端口映射到主机的 8000 端口
```
