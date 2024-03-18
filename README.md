# compress
这是一个Docker命令行图片压缩工具，支持指定路径下过滤图片大小进行压缩

#### 安装

```bash
docker run -d --name compress -v /path/to:/app/data liziwa/compress
```

#### 使用

```bash
docker exec -it CONTAINER_ID /bin/bash
img_compress.sh ./imgs 1M
```

#### 参数

` JPG_QUALITY ` jpg 格式的图片压缩率，范围 0 - 100，默认 75，数字越小压缩率越高

` PNG_QUALITY ` png 格式的图片压缩率，范围 0 - 100 | auto，默认 auto，数字越小压缩率越高
