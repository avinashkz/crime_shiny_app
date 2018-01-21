
# uiOutput("crime"),
# uiOutput("homicide"),
# uiOutput("rape"),
# uiOutput("robbery"),
# uiOutput("assault")



output$yearOutput <- renderUI({
  sliderInput(
    "year",
    h5("Range of Years:"),
    min = min(crime$year),
    max = max(crime$year),
    value = c(2003, 2015),
    sep = "",
    step = 1
  )
})
output$crime <- renderUI({
  sliderInput(
    "crime",
    h5("Range of Years:"),
    min = round(min(crime$violent_per_100k,na.rm = TRUE)),
    max = round(max(crime$violent_per_100k,na.rm = TRUE)),
    value = c(min(crime$violent_per_100k,na.rm = TRUE), max(crime$violent_per_100k,na.rm = TRUE)),
    sep = "", 
    round = TRUE, step = 20
  )
})

output$homicide <- renderUI({
  sliderInput(
    "homicide",
    h5("Range of Years:"),
    min = min(crime$homs_sum,na.rm = TRUE),
    max = max(crime$homs_sum,na.rm = TRUE),
    value = c(min(crime$homs_sum,na.rm = TRUE), max(crime$homs_sum,na.rm = TRUE)),
    step = 1000,
    sep = ""
  )
})

output$rape <- renderUI({
  sliderInput(
    "rape",
    h5("Range of Years:"),
    min = min(crime$rape_sum,na.rm = TRUE),
    max = max(crime$rape_sum,na.rm = TRUE),
    value = c(min(crime$rape_sum,na.rm = TRUE), max(crime$rape_sum,na.rm = TRUE)),
    sep = ""
  )
})

output$robbery <- renderUI({
  sliderInput(
    "robbery",
    h5("Range of Years:"),
    min = min(crime$rob_sum,na.rm = TRUE),
    max = max(crime$rob_sum,na.rm = TRUE),
    value = c(min(crime$rob_sum,na.rm = TRUE), max(crime$rob_sum,na.rm = TRUE)),
    sep = ""
  )
})

output$assault <- renderUI({
  sliderInput(
    "assault",
    h5("Range of Years:"),
    min = min(crime$agg_ass_sum,na.rm = TRUE),
    max = max(crime$agg_ass_sum,na.rm = TRUE),
    value = c(min(crime$agg_ass_sum,na.rm = TRUE), max(crime$agg_ass_sum,na.rm = TRUE)),
    sep = ""
  )
})



