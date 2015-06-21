
# Project for Developing Data Products
# Author Teresa Nieten
# March 2015
# 
# Drawing wordclouds from a selected story
# Select radio button for story to display the wordcloud for that story.
#
#

library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Words from Stories"),
  
  # Sidebar with a slider input for number of bins
  sidebarPanel(
    helpText("Discover most frequently used words in common stories"),
    radioButtons("id1",
                "Story:",
                c("Twas the Night Before Christmas",
                  "The Birth of Pecos Bill",
                  "Paul Bunyan and Babe the Blue Ox",
                  "Cinderella",
                  "Gettysburg Address",
                  "US Constitution"), selected= NULL),
    sliderInput("id2", "Choose Maximum Number of Words", min=50, max=200, value=100, step=10)
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    
    textOutput("title"),
    textOutput("grade"),
    plotOutput("cloud")

    
  )
))
