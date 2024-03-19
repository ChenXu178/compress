# img_compress

这是一个Docker命令行图片压缩工具，对指定路径下的 jpg 、png 格式的图片进行压缩，可选图片压缩率，能大幅减少图片文件的空间占用

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
  img_compress.sh -f all -j 80 -p 80 -m 1M ./img
  ```

- **图片格式转换**

  ```
  convert.sh jpg ./img
  ```
  
- **文件大小排序**

  ```bash
  size_sort.sh dsc ./img
  ```

#### 环境变量

` JPG_QUALITY ` jpg 格式的图片压缩率，范围 0 - 100，默认 75，数字越小压缩率越高

` PNG_QUALITY ` png 格式的图片压缩率，范围 0 - 100 | auto，默认 auto，数字越小压缩率越高
