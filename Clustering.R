# This script presents all steps to cluster students' answers into groups 
#     in order to discover hidden patterns in students' answers.

# For clustering, we used k-means clustering algorithm.

# Load the libraries required.
library(tm)         # Text mining library
library(pdist)      # Required for knn (calculating distance in k-means)
library(SnowballC)  # Required for stemming
library(factoextra) # Required for clustering
library(flexclust)  # Required for clustering
library(wordcloud)  # Required for word clouds

# Specify the directories to read students' answers and write the final files and figures.
# Directory with source files (answers)
sourceDir = "\\.\\experiment"
# Directory to write files
outDir = "\\.\\experiment"


# Load students' answers for the first question  from the source directory as 'First'.
# 'First' is the txt file containing all students' answers for the first question. In the data used, it was saved as 
First = read.delim(paste0(sourceDir, '\\First.txt'), header=FALSE)

# Create the DTM (Document Term Matrix) with all students' answers for the first question.

# 'cleaning' is a function to apply pre-processing steps to students' answers 
#     to be later used to create DTM. 'dataclean' is students' answers (First).

      cleaning = function(dataclean)
      {
        a1 = as.character(dataclean[,1])
        a1 = gsub("<.*?>"," ", a1)
        a1 = gsub("[.,]", " ", a1)
        a1 = gsub("[^0-9A-Za-z///' ]", " ", a1)
        a1 = VCorpus(VectorSource(a1))
        # Change cases to lower
        a1 = tm_map(a1, content_transformer(tolower))
        # Remove Numbers
        a1 = tm_map(a1, removeNumbers)
        # Remove Punctuation
        a1 = tm_map(a1, removePunctuation) 
        # Stem words to get rid of variety of ending for words so that they are uniform. 
        a1 = tm_map(a1, stemDocument)   
        # remove stop words
        a1 = tm_map(a1, removeWords, stopwords("english")) 
        # Strip white spaces
        a1 = tm_map(a1, stripWhitespace) 
        # Tell R  to treat the pre-processed documents as text documents.
        a1 = tm_map(a1, PlainTextDocument)  
        
        return(a1)
      }


# Clean the answer
ans = cleaning(First)

# Check the text
# ans[[1]]$content      

# Create DTM for the answers
DTM = DocumentTermMatrix(ans)

# Remove words appearing in less than 10% of answers in the corpus.
DTM = removeSparseTerms(DTM,0.9)

# Convert DTM into matrix (DDTM)
DDTM = as.matrix(DTM)

# Remove those words appearing in question sentence.
# Words should be described for each question individually. Words appearing in question sentence are removed for the first question.
# If there is a word appering in both model answer and the question sentence, this should not be removed. 
DDTM = DDTM[ , !( colnames( DDTM ) %in% c('problem') ) ]
DDTM = DDTM[ , !( colnames( DDTM ) %in% c('solv') ) ]
DDTM = DDTM[ , !( colnames( DDTM ) %in% c('role') ) ]
DDTM = DDTM[ , !( colnames( DDTM ) %in% c('prototyp') ) ]
DDTM = DDTM[ , !( colnames( DDTM ) %in% c('program') ) ]

# Apply k-means clustering to group students' answers. 
# Determining the number of clusters by elbow method.

# There are 29 students' answers for the first question. Give rownames for them.
row.names(DDTM) = c(1:29)

# Normalise the answers. We used L2 normalisation. 
DDTM = DDTM/sqrt(rowSums(DDTM^2)) 
# Convert NAs into 0s in the matrix
DDTM[is.na(DDTM)]  = 0

# Use Elbow method to determine the number of clusters to be used in k-means.
fviz_nbclust(DDTM, kmeans, method = "wss") + theme_bw()

# After determining the number of clusters, apply clustering. 
# We applied k-means with 3 clusters (k=3).

set.seed(2)
Cluster = kcca(DDTM, k=3, family=kccaFamily("kmeans"))
# Check clusters to be sure that there is no singleton cluster. 
clusters(Cluster)

# Save student-word matrix , words and word clouds for each cluster.
# The number of clusters should be changed in the for loop (1:3 for our case).

for (i in 1:3){
 ddtm = DDTM[which(clusters(Cluster)==i),] 
 dim = dim(ddtm)
 # Create binary matrix for calculating the frequency that students usage of words in clusters
 for (j in 1:dim[2]) {ddtm[which(ddtm[,j]>0),j]=1}
 # Sort words by in decreasing order
 vec = sort(colSums(ddtm),decreasing=TRUE)
 words = data.frame(word = names(vec),freq=vec)
 
 # Write student-word matrix and words
 filename = filename=paste('cluster',i) 
 
 write.csv(ddtm, file = paste0(outDir,'\\',filename,'_matrix',".csv" ))
 write.csv(words,file = paste0(outDir,'\\',filename,'_words',".csv" ))
 
 # Plot the word clouds for each clusters
 file.name = paste0(outDir,'\\','Cluster',i,'.png')
 png(file = file.name,width=300, height=300)
 set.seed(1234)
 wordcloud(words$word,words$freq,random.order=FALSE,min.freq = 1,  max.words=200, rot.per=0.35, use.r.layout=FALSE,colors=brewer.pal(8, "Dark2"))
 dev.off()
}


####################################
# This section of the code calculates the distance between the students' answers and the model answer 
#     to be used in the Mathematical Model to predict students' marks. 
#     In other words, the number of words that a student usd from the model answer.
#
# 'ANSWER.txt' is the txt file containing the model answer for the first question. 


# Determine the number of students' answers for the question. For the first question, it is 29.
num_ans = 29

Answer = read.delim(paste0(sourceDir, '\\ANSWER.txt'), header=FALSE)
# Bind rows of the model answer and the students' answers to be used in calculation of distance. The first row is the model answer. 
data = rbind(Answer,First)

# Extract the words in the model answer.
model_words = cleaning(Answer)
DTM_model = DocumentTermMatrix(model_words)
model_words = DTM_model$dimnames[[2]]

# Create the matrix containing the model answer and all students' answers. The columns of the matrix will be only 'model words'.
#  The number of rows of the matrix for the first question will be 30 as there are 29 students' answers.
data_all = cleaning(data)
DTM_all = DocumentTermMatrix(data_all)
DDTM_all = as.matrix(DTM_all)

# For the first question, we applied a user defined step to identify synonyms of model words in student asnwers/  
#   For instance, there are different spelling of behaviour student answers (behaviour and behavior). We combined them. 
#   We also consider typos in students answers (stimul instead of simul) and a possible usage for portion (part). We united these columns as one.
 
behaviour = rowSums(DDTM_all[,c("behaviour", "behavior")])
simul =  rowSums(DDTM_all[,c("simul", "stimul")])
portion  = rowSums(DDTM_all[,c("portion", "part")])

# Remove the dublicated columns
DDTM_all = DDTM_all[ , !(colnames(DDTM_all) %in% c('behaviour'))]
DDTM_all = DDTM_all[ , !(colnames(DDTM_all) %in% c('simul'))]
DDTM_all = DDTM_all[ , !(colnames(DDTM_all) %in% c('portion'))]
DDTM_all = cbind(DDTM_all,behaviour,simul,portion)

# Extract only model words and create the dictionary
DDTM_all = DDTM_all[ ,(colnames(DDTM_all) %in% model_words)]
# Make DDTM_all binary
for (j in 1:dim(DDTM_all)[2]) {DDTM_all[which(DDTM_all[,j]>0),j]=1}
rownames(DDTM_all) = c('model',1:num_ans) 

# Calculate the Menhatten Distance between the first row(model answer) and the students' answers.
dist = dist(DDTM_all,method='manhattan')
dist = as.matrix(dist)
dist = dist[1:num_ans+1,1]

# Write Distances for each student answer from the Model answer
write.csv(dist, file = paste0(outDir,'\\','Distances',".csv" ))
