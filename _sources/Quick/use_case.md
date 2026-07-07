# Use case

See <project:../usecase/index.rst> section for how to start an analysis task.

## Automating Configuration with LLMs

Manually writing `sample_sheet.csv` and `project_config.yaml` is tedious and error-prone, especially for large cohorts with complex naming conventions. The [YULUMINA](https://github.com/zyllifeworld/YULUMINA) repository provides a `clindet` skill that lets you configure a Clindet analysis entirely through conversation with an LLM — no hand-editing of config files required.

### How it works

The `clindet` skill encodes Clindet's configuration rules, software profiles, run-type matrix, and sample-naming conventions into structured reference files. When loaded by an LLM (Claude Code, OpenAI Codex CLI, or any tool that supports skills), it conducts an interview with you to collect:

- Sequencing type (WES / WGS / targeted panel / RNA-seq)
- Species and genome version
- FASTQ file locations and naming patterns
- BED file information
- Project name, output directory, and analysis scope
- Compute environment (local node or Slurm HPC)

After the interview, the LLM generates all required project files:

- `project_config.yaml` — workflow configuration
- `sample_sheet.csv` — sample metadata and pairing
- `run_dryrun.sh` — dry-run command for validation
- `submit_pipeline.sh` — production submission script
- `run_info.md` — run summary for documentation
- `data_sanity_report.md` — data quality notes for review

### Installation

Clone YULUMINA and symlink the `clindet` skill into your LLM tool's skills directory:

**Claude Code:**

```bash
git clone https://github.com/zyllifeworld/YULUMINA.git /your/preferred/path/YULUMINA
ln -s /your/preferred/path/YULUMINA/clindet ~/.claude/skills/clindet
```

**OpenAI Codex CLI:**

```bash
git clone https://github.com/zyllifeworld/YULUMINA.git /your/preferred/path/YULUMINA
ln -s /your/preferred/path/YULUMINA/clindet ~/.codex/skills/clindet
```

### Usage

Once the skill is installed, start a conversation with your LLM and describe your analysis. For example:

> "I have paired WES data for 10 tumor-normal samples under ~/projects/cancer_wes/data/. The files are named like T_<sample>_R1.fq.gz. I want to run somatic SNV and CNV calling on b37."

The LLM will ask clarifying questions, then generate all config files ready to use with the `snakemake` commands described in [Run the Quick Test](../Quick/install#run-the-quick-test).

For details on the skill's capabilities and design, see the [YULUMINA README](https://github.com/zyllifeworld/YULUMINA).