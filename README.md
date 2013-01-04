    _.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,

      .,-:::::/   :::. :::::::::::: ::   .: .,:::::: :::::::..  .,:::::: :::::::..   
    ,;;-'````'    ;;`;;;;;;;;;;'''',;;   ;;,;;;;'''' ;;;;``;;;; ;;;;'''' ;;;;``;;;;  
    [[[   [[[[[[/,[[ '[[,   [[    ,[[[,,,[[[ [[cccc   [[[,/[[['  [[cccc   [[[,/[[['  
    "$$c.    "$$c$$$cc$$$c  $$    "$$$"""$$$ $$""""   $$$$$$c    $$""""   $$$$$$c    
     `Y8bo,,,o88o888   888, 88,    888   "88o888oo,__ 888b "88bo,888oo,__ 888b "88bo,
       `'YMUP"YMMYMM   ""`  MMM    MMM    YMM""""YUMMMMMMM   "W" """"YUMMMMMMM   "W" 

    `'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`'~,_.~'`


# Gatherer: The Magicking

Gatherer is a gem to scrape Magic: The Gathering card data from [gatherer.wizards.com](http://gatherer.wizards.com).

To grab a card you'll need the Multiverse ID; these IDs uniquely identify cards within gatherer.

    client = Gatherer::Client.new
    client.fetch_by_multiverse_id(111)

The fetch will give you a complete Gatherer::Card with any data that could be scraped from gatherer.
If you use a non-existent Multiverse ID you will get a Gatherer::CardNotFound error.

If you have any questions or you'd like this gem to do something else feel free to contact me.
