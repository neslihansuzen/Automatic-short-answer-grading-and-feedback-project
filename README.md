# Automatic-short-answer-grading-and-feedback-project
R code for automatic short answer grading and feedback project

This repository contains R codes for applying k-means clustering to the collection of students' answers in order to discover hidden patterns in answers. It also contains the calculation of the distance between the students' answers and the model answer that is used to apply a mathematical model to predict students' marks. Detailed description of the model can be found in [1]. All further calculations and ploting figures were done by using tools in Excel. 

## What is 'Clustering.R'?

**Clustering. R** is an R code that processes the collection of students' answers and create clusters of answers, and calculate the distance between the students' answer and the model answer. 'Distance' refers the number of words that a student used from the model answer.   

The code requires the following R packages: tm, pdist, SnowballC, factoextra, flexclust, wordcloud. Packages can be installed by

     install.packages(c("tm","pdist","SnowballC","factoextra","flexclust","wordcloud"))

The script of the code contains 2 parameters of paths 'sourceDir' and 'outDir' described below:

     sourceDir     : Directory with source files (students' asnwers and the model answer files)
     outDir        : Directory to write processed files (frequencies and words in clusters) and figures (word clouds)

These locations should be changed by the user for reading and writing files.

The code consists of the function '**Cleaning**' to apply pre-processing to the collection of students' answers. Preprocessing function consists the following operations:

1. **Removing punctuations and special characters**: This is the process of substitution of all non -alphanumeric characters by space .
Lowercasing the text data: Entire collection of texts are converted to lowercase.

2. **Removing numbers**: All digits which are not included in a word are replaced by space. 

3. **Stemming**: In this process, multiple forms of a specific word are eliminated and words that have the same base in different grammatical forms are mapped to the same stem.

4. **Stop words removal**: All English stop words listed in the tm package are removed.

We also removed words appearing in less than 10% of answers in the corpus and those words appearing in question sentence.

   ### Guide for Usage the Code

1. Install libraries
2. Change paths of directories for reading and writing files
3. Run the code

   ### Outputs of the Code
All output files are saved in the 'outDir'. The outputs of the code are listed below:

1.**Cluster i_matrix.csv**: This is the matrix of students-words in each cluster i. Each entity of the matrix shows the presence/absence (binary) of a word in the corresponding student answer.

2.**Cluster i_words.csv**: 'Cluster i_words' contains words and their frequencies in the cluster i. Frequency refers the number of students using the word in the answer. Words are oredered by the frequencies in descending order. 

3.**Cluster i.png**: This figure shows the words clouds where words are used by students in the cluster i. The font and color of words indicate different frequencies of words. 

4.**Distances.csv**: Tis file contains the distances between the sudents' answers and the model answers, i.e., the number of words that students used from the model answers.

  ### The Dataset
 
The dataset used in the project was downloaded from the archive hosted at the URL http://lit.csci.unt.edu/index.php/Downloads. It is available at the following link https://github.com/dbbrandt/short_answer_granding_capstone_project/tree/master/data/source_data/ShortAnswerGrading_v2.0 (accessed 16 December 2019).  
 
The dataset  consists of students answers and model answers for 10 assignments and 2 exam questions. These exams and assignments are from the introductory computer science class in the University of North Texas. For each question, there is one model answer in the data. The answers have scored by two human judges, with a maximum 5 (correct answers) and minimum 0 (completely incorrect).
 
 
[1] Suzen, N., Gorban, A., Levesley, J., & Mirkes, E. (2018). Automatic Short Answer Grading and Feedback Using Text Mining Methods. arXiv preprint arXiv:1807.10543.

