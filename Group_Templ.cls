\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{Group_Templ}[2026/10/16 Exercise template]

\LoadClass[a4paper,10pt]{article}

% Packages
\RequirePackage[T1]{fontenc}
\RequirePackage{graphicx}
\RequirePackage{amsmath}
\RequirePackage{pgffor}
\RequirePackage{enumitem}
\RequirePackage{minted}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{hyperref}
\RequirePackage{currfile}

% Load configuration
\InputIfFileExists{config.tex}{}{%
    \ClassError{Group_Templ}
        {Missing config.tex}
        {Create a config.tex file containing group information.}%
}

% Page layout
\geometry{
    a4paper,
    left=20mm,
    right=20mm,
    top=20mm,
    bottom=20mm
}

% Require sheet number from build system
\@ifundefined{SheetNumber}{%
    \ClassError{Group_Templ}
        {Missing sheet number}
        {The build system must define \string\SheetNumber.}%
}{}

% Header and footer
\pagestyle{fancy}
\fancyhf{}

\fancyhead[L]{Übungsblatt \SheetNumber}
\fancyhead[R]{Gruppe \GroupID\ $\mid$ \GroupMembers}
\fancyfoot[C]{\thepage}

% PDF metadata
\AtBeginDocument{%
    \hypersetup{
        pdfauthor={Gruppe \GroupID},
        pdftitle={\CourseName: Übungsblatt \SheetNumber},
        pdfproducer={LaTeX}
    }
}

\endinput
