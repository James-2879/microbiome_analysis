% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/barplot.R
\name{make_stacked_barplot}
\alias{make_stacked_barplot}
\title{Make a stacked bar plot of species abundance.}
\usage{
make_stacked_barplot(data, orientation = "vertical", max = 10)
}
\arguments{
\item{data}{data frame}

\item{orientation}{string (vertical/horizontal)}

\item{max}{integer (max number of entries to display (ordered by decreasing abundance),
any further entries are categorized into 'Other')}
}
\value{
ggplot object (CLI will save plot as image)
}
\description{
Creates a stacked bar plot of mean abundance of species for each source (as a 
fraction of total abundance per source).
}
