# ENA Metagenome Downloader

通过 ENA Portal API 下载 FASTQ 文件。**下载默认在 screen 后台运行**，退出终端也不会中断。

## 快速安装

```bash
git clone https://github.com/zhijianxiao/sra-download-skill.git
cd sra-download-skill
chmod +x download_sra.sh

# 安装依赖（Ubuntu / Debian）
sudo apt install curl wget screen
```

## 常用命令

| 场景 | 命令 |
|------|------|
| 下载单个 SRR | `bash download_sra.sh SRR11066123` |
| 下载整个项目 | `bash download_sra.sh PRJNA1074950` |
| 指定下载目录 | `bash download_sra.sh PRJNA1074950 /home/user/data` |
| 从 txt 列表批量下载 | `bash download_sra.sh --file my_list.txt /home/user/data` |
| 前台运行（不用 screen） | `bash download_sra.sh SRR11066123 --foreground` |

## 使用示例

### 1. 下载单个 Run

```bash
bash download_sra.sh SRR11066123
```

### 2. 下载整个 BioProject（PRJNA / PRJEB）

```bash
bash download_sra.sh PRJNA1074950 /home/user/downloads
```

自动解析项目下所有 SRR / ERR / DRR 并下载。

### 3. 从本地 txt 列表批量下载

创建 `my_list.txt`，每行一个 accession：

```
# 我的下载列表
SRR11066123
SRR11066124
ERR1234567
```

```bash
bash download_sra.sh --file my_list.txt /home/user/data
```

### 4. 前台运行（调试用）

```bash
bash download_sra.sh SRR11066123 --foreground
```

## 查看下载进度 & 日志

| 操作 | 命令 |
|------|------|
| 查看所有 screen 会话 | `screen -list` |
| 进入会话看实时进度 | `screen -r PRJNA1074950` |
| 退出会话（不中断下载） | 按 `Ctrl+A` 再按 `D` |
| 实时查看日志 | `tail -f PRJNA1074950/download.log` |
| 停止下载 | `screen -S PRJNA1074950 -X quit` |

## 输出结构

```
/home/user/downloads/
└── PRJNA1074950/
    ├── SRR11066123_1.fastq.gz
    ├── SRR11066123_2.fastq.gz
    ├── SRR11066124.fastq.gz
    ├── ...
    └── download.log
```

## 参数说明

```
bash download_sra.sh <ACCESSION> [OUTPUT_DIR] [OPTIONS]
bash download_sra.sh --file <LIST.txt> [OUTPUT_DIR] [OPTIONS]
```

| 参数 | 说明 |
|------|------|
| `ACCESSION` | PRJNA / PRJEB / SRR / ERR / DRR ... |
| `OUTPUT_DIR` | 下载目录（可选，默认当前目录） |

| 选项 | 说明 |
|------|------|
| `--file FILE` | 从本地 txt 读取 accession 列表（每行一个，# 开头为注释） |
| `--foreground` | 前台运行，不创建 screen 会话 |
| `--show-progress` | 强制显示进度条（终端下默认自动） |
| `-h, --help` | 显示帮助 |

## 功能特点

- **默认后台运行** — 自动创建 screen 会话，断开 SSH 不中断
- **断点续传** — `wget -c` 支持中断恢复，已下载文件自动跳过
- **自动重试** — 下载失败自动重试 3 次
- **批量下载** — 支持 txt 列表一次性提交多个 accession
- **日志完整** — 每个任务独立 `download.log`，记录耗时、大小、状态
- **无需 SRA Toolkit** — 直接下载 `.fastq.gz`
