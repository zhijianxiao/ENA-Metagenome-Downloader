# SRA Download Skill

一个基于 SRA Toolkit 的自动化脚本，用于下载 NCBI SRA 数据库中的测序数据，并将其转换为压缩的 FASTQ 格式。

## 功能特点

- **一键下载** — 只需提供 SRR 编号，自动完成下载、转换和压缩全流程
- **FASTQ 转换** — 使用 `fasterq-dump` 将 SRA 格式转换为通用的 FASTQ 格式
- **自动压缩** — 转换完成后使用 `gzip` 压缩 FASTQ 文件，节省存储空间
- **日志记录** — 每个样本独立生成日志文件，方便追踪和排错
- **结构化输出** — 每个 SRR 样本输出到独立目录，便于管理

## 环境要求

| 依赖 | 说明 |
| ---- | ---- |
| [SRA Toolkit](https://github.com/ncbi/sra-tools) | 需要安装 `prefetch` 和 `fasterq-dump` 命令 |
| Bash | Linux / macOS / WSL / Git Bash |
| gzip | 通常系统自带 |

## 安装教程

### 1. 安装 SRA Toolkit

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install sra-toolkit
```

**macOS:**
```bash
brew install sra-toolkit
```

**Windows:**
通过 [WSL](https://learn.microsoft.com/en-us/windows/wsl/) 或 [Git Bash](https://git-scm.com/) 运行，并从 NCBI 官网下载 SRA Toolkit 安装包。

### 2. 获取本项目

```bash
git clone <repo-url> sra-download-skill
cd sra-download-skill
```

### 3. 验证安装

```bash
prefetch --version
fasterq-dump --version
```

确保两个命令均可正常执行。

## 使用方法

```bash
bash download_sra.sh <SRR_ID>
```

| 参数 | 说明 | 示例 |
| ---- | ---- | ---- |
| `SRR_ID` | NCBI SRA 数据库中的 Run 编号 | `SRR29350539` |

### 执行流程

1. `prefetch` — 下载 `.sra` 文件到 `output/<SRR_ID>/`
2. `fasterq-dump` — 将 SRA 文件转换为 FASTQ 文件
3. `gzip` — 将 FASTQ 文件压缩为 `.fastq.gz`

## 输出结果说明

执行完成后，项目目录结构如下：

```
sra-download-skill/
├── download_sra.sh
├── output/
│   └── <SRR_ID>/
│       ├── <SRR_ID>.sra        # 原始 SRA 文件
│       ├── <SRR_ID>_1.fastq.gz  # 双端测序 Read 1（压缩）
│       └── <SRR_ID>_2.fastq.gz  # 双端测序 Read 2（压缩，单端测序时无此文件）
├── logs/
│   └── <SRR_ID>.log            # 运行日志
└── README.md
```

- **单端测序**：只生成一个 `.fastq.gz` 文件，命名为 `<SRR_ID>.fastq.gz`
- **双端测序**：生成两个 `.fastq.gz` 文件，分别以 `_1` 和 `_2` 后缀区分

## 示例运行

```bash
$ bash download_sra.sh SRR29350539

[INFO] Downloading SRA...
[INFO] Download completed
[INFO] Converting to FASTQ...
[INFO] FASTQ conversion completed
[INFO] Compressing FASTQ files...
[INFO] Compression completed
[INFO] All steps completed successfully
FASTQ files: /path/to/sra-download-skill/output/SRR29350539
Log file:    /path/to/sra-download-skill/logs/SRR29350539.log
```

运行后即可在 `output/SRR29350539/` 目录下获得压缩的 FASTQ 文件，直接用于下游分析（如质量控制、序列比对等）。
