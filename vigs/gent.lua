-- A gentleman calls

return {
		name = "gent1",
		title = "A Gentleman Calls",
		subtitle = "You are in your room when you hear a knock at the door",
		scene = "livingroom1",
		nodes = {
				[1] = {
						"You are lay ",
						"As is this",
						{
							type = "choice",
							text = "This is a choice you can make",
							choices = {
									{ 
										text = "This is option A",
										gotoNode = 2
									},
									{
										text = "This is option B",
										gotoNode = function() return 3 end,
										set = { name = "myValue", value = "1" }
									}
								
								}
						}
					},
				[2] = {
						"This is the second node",
						"This is another thingy",
					
				},
				[3] = {
						"This is the third node",
						"This is another thingy",
					
					}
			
			
			}
	
	
	}