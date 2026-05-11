# ENA Metagenome Downloader

通过 ENA Portal API 批量下载指定项目（PRJNA / PRJEB）下所有测序 run 的 FASTQ 文件，无需手动逐个查询和下载。

## 功能特点

- **项目级下载** — 输入 PRJNA 或 PRJEB 编号，自动拉取该项目的全部 run
- **ENA API 查询** — 通过 ENA Portal API 获取每个 run 的 accession、FASTQ 下载地址和文库布局信息
- **自动下载列表** — API 返回的原始 TSV 保存为项目下载清单，方便追溯
- **Paired-end 支持** — 双端测序自动下载 Read 1 和 Read 2 两个文件
- **断点续传** — `wget -c` 支持中断后恢复下载
- **进度显示** — 终端实时显示每个文件的下载进度条
- **结构化输出** — 每个项目独立目录，每个 run 独立子目录，清晰管理
- **完整日志** — 输出同时写入日志文件，便于事后排查

## 环境要求

| 依赖 | 说明 |
| ---- | ---- |
| `curl` | 查询 ENA API |
| `wget` | 下载 FASTQ 文件（支持断点续传） |
| Bash | Linux / macOS / WSL |

安装依赖：

```bash
# Ubuntu / Debian
sudo apt install curl wget

# macOS
brew install curl wget
```

## 安装教程

```bash
git clone https://github.com/zhijianxiao/sra-download-skill.git
cd sra-download-skill
chmod +x download_ena.sh
```

## 使用方法

```bash
bash download_ena.sh <PROJECT_ID>
```

| 参数 | 说明 | 示例 |
| ---- | ---- | ---- |
| `PROJECT_ID` | NCBI / ENA 项目编号 | `PRJNA210709`、`PRJEB12345` |

### 执行流程

1. 调用 ENA Portal API 查询项目下所有 run
2. 保存 TSV 下载清单到项目目录
3. 逐 run 解析 FASTQ 下载地址
4. `wget` 下载 `.fastq.gz` 文件并显示进度
5. 输出运行摘要（成功 / 失败数）

## 输出结果说明

```
/mnt/hdd2/cxj-download/metagenome/
└── <PROJECT_ID>/
    ├── <PROJECT_ID>.download_list.tsv   # API 原始下载清单
    ├── logs/
    │   └── download.log                 # 完整运行日志
    ├── SRR11066123/                     # Run 子目录
    │   ├── SRR11066123_1.fastq.gz       # Paired-end Read 1
    │   └── SRR11066123_2.fastq.gz       # Paired-end Read 2
    └── SRR11066124/                     # Single-end 示例
        └── SRR11066124.fastq.gz
```

- **Paired-end**：每个 run 目录下包含 `_1.fastq.gz` 和 `_2.fastq.gz` 两个文件
- **Single-end**：每个 run 目录下包含一个 `.fastq.gz` 文件

## 示例运行

```bash
$ bash download_ena.sh PRJNA210709

[INFO] Project:     PRJNA210709
[INFO] Output:      /mnt/hdd2/cxj-download/metagenome/PRJNA210709
[INFO] Timestamp:   2026-05-11 14:30:00
[INFO] Querying ENA API...
[INFO] Download list → .../PRJNA210709.download_list.tsv
[INFO] Total runs:   2

============================================================
[1/2] SRR11066123  (PAIRED)
============================================================
[DOWNLOAD] SRR11066123_1.fastq.gz
  URL:  ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR110/023/...
  →     .../SRR11066123/SRR11066123_1.fastq.gz
  [OK]

[DOWNLOAD] SRR11066123_2.fastq.gz
  URL:  ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR110/023/...
  →     .../SRR11066123/SRR11066123_2.fastq.gz
  [OK]

============================================================
[2/2] SRR11066124  (SINGLE)
============================================================
[DOWNLOAD] SRR11066124.fastq.gz
  URL:  ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR110/024/...
  →     .../SRR11066124/SRR11066124.fastq.gz
  [OK]

============================================================
[INFO] All done — 2026-05-11 14:35:00
  Success: 2/2
  Output:  /mnt/hdd2/cxj-download/metagenome/PRJNA210709
  Log:     .../logs/download.log
  List:    .../PRJNA210709.download_list.tsv
============================================================
```
