# img_compress

这是一个Docker命令行图片转换/压缩工具，对指定路径下的图片进行格式转换、压缩，可选图片压缩率，能大幅减少图片文件的空间占用，支持 jpg / png / webp / avif / heic 格式的图片。

#### 安装

```bash
docker run -d --name ImgCompress -v /path/to:/app/data liziwa/img_compress
```

#### 使用

```bash
docker exec -it CONTAINER_ID /bin/bash
```

- **压缩图片**

  ```bash
  icompress.sh -f all -j 75 -p auto -w 75 -m 1M ./img
  ```

- **图片格式转换**

  ```
  iconvert.sh jpg ./img
  ```
  
- **文件大小排序**

  ```bash
  size_sort.sh dsc ./img
  ```

#### 环境变量

` PGID ` Docker 运行时的用户组

` PUID ` Docker 运行时的用户

` UMASK ` Docker 创建文件的掩码