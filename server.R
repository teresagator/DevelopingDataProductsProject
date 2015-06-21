
# Server logic for Developing Data Products project
# Author: Teresa Nieten
#

library(shiny)
if (!require(XML)) {
  install.packages("XML")
  library(XML)
}
if (!require(tm)) {
  install.packages("tm")
  library(tm)
}
if (!require(wordcloud)) {
  install.packages("wordcloud")
  library(wordcloud)
}
if (!require(RColorBrewer)) {
  install.packages("RColorBrewer")
  library(RColorBrewer)
}

if (!require(koRpus)) {
  install.packages("koRpus")
  library(koRpus)
}

shinyServer(function(input, output) {
  # Create title for the word cloud 
    output$title <- renderText({
    paste("Word Cloud for '", input$id1, "'")
  })
  
  output$cloud <- renderPlot({
    
    # Read and parse HTML file
    if (input$id1 == "Twas the Night Before Christmas") {
      # Parse the html page
      doc.html = htmlTreeParse('http://www.night.net/christmas/twas-the-night.html',
                             useInternal = TRUE)
      # Assign the tag that is used in that website to contain the text
      tag <- '//td'
      
    } else if (input$id1 == "The Birth of Pecos Bill") {
      # Birth of Pecos Bill
      doc.html = htmlTreeParse('http://americanfolklore.net/folklore/2010/08/the_birth_of_pecos_bill.html',
                               useInternal = TRUE)
      tag <- '//*/div[@class=\'entry-body\']'
    }
    else if (input$id1 == "Paul Bunyan and Babe the Blue Ox") {
      # Paul Bunyan
      doc.html = htmlTreeParse('http://americanfolklore.net/folklore/2010/07/babe_the_blue_ox.html', 
                               useInternal = TRUE)
      tag <- '//*/div[@class=\'entry-body\']'
    } 
    else if (input$id1 == "Cinderella") {
      # Cinderella
      doc.html = htmlTreeParse('http://www.pitt.edu/~dash/grimm021.html', 
                               useInternal = TRUE)
      tag <- '//p'
    }
    else if (input$id1 == "Gettysburg Address") {
      # Lincoln's Gettysburg Address
      doc.html = htmlTreeParse('http://www.ourdocuments.gov/print_friendly.php?flash=true&page=transcript&doc=36&title=Transcript+of+Gettysburg+Address+%281863%29', 
                               useInternal = TRUE)
      tag <- '//p'
    }
    
    else if (input$id1 == "US Constitution") {
      # Transcript of Constitution of the United States
      doc.html = htmlTreeParse('http://www.ourdocuments.gov/print_friendly.php?flash=true&page=transcript&doc=9&title=Transcript+of+Constitution+of+the+United+States+%281787%29', 
                               useInternal = TRUE)
      tag <- '//p'
    }
    # Extract all the paragraphs (HTML tag is dependent on the site). 
    # Unlist flattens the list to create a character vector.
    doc.text = unlist(xpathApply(doc.html, tag, xmlValue))
    
    # Replace all \n by spaces. This gives a warning about absolute paths becuase of the \\
    doc.text = gsub('\\n', ' ', doc.text)
    
    # Join all the elements of the character vector into a single
    # character string, separated by spaces
    doc.text = paste(doc.text, collapse = ' ')
    
    # Compute the reading level for later display.  
    # flesch.kincaid returns an object of class
    # kRp.readability-class, so the grade level must be extracted from
    # the summary
    output$grade <- renderText({   
                               tokens <- tokenize(doc.text, format="obj", lan="en")
                               grade <- flesch.kincaid(tokens)
                               fk_grade <- summary(grade, flat=TRUE)
                               paste("Flesch Kincaid reading level: ", fk_grade, " grade")
  }) 

    # On to the word cloud
    # Create a corpus
    doc.corpus <- Corpus(DataframeSource(data.frame(doc.text)))
    
    # Remove the punctuation
    doc.corpus <- tm_map(doc.corpus, removePunctuation)
    
    # Convert all to lower case
    doc.corpus <- tm_map(doc.corpus, tolower)
    
    # Remove common English stopwords.  May not want to do this in some 
    # applications
    doc.corpus <- tm_map(doc.corpus, function(x) removeWords(x, stopwords("english")))

    # Convert to a matrix for determining word frequencies
    tdm <- TermDocumentMatrix(doc.corpus)
    mat <- as.matrix(tdm)
    v <- sort(rowSums(mat), decreasing=TRUE)
    d <- data.frame(word = names(v), freq=v)
    pal <- brewer.pal(6, "Dark2")
    
  # Generate the word cloud for plotting
    wordcloud(d$word, d$freq, min.freq=2, max.words=input$id2, scale=c(3.5,.2), random.order=T, colors=pal)
  
  }, width=2200, height=1500, res=350)

})
