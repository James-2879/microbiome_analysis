library(DESeq2)
library(tidyverse)

diagdds <- phyloseq_to_deseq2(physeq_object, ~ 1) # replace 1 with whatever the var to compare is
diagdds <- DESeq(diagdds, test="Wald", fitType="parametric")

volcano_plot <- ggplot(data = diagdds, aes(x = log2FoldChange, y = -log10(pvalue))) +
  geom_point(color = ifelse(diagdds$padj < 0.05, "red", "black"), alpha = 0.5) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "blue") +  
  labs(x = "Log2 Fold Change", y = "-Log10 p-value", title = "Volcano Plot") +
  theme_minimal()
