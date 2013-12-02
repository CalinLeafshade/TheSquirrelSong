--maps

return 
	{
		[1] = {
				{
					length = 900,
					angle = "forward",
					{
						type = "spot",
						link = true
					}
				},
				{
					length = 750,
					angle = "forward",
					{
						type = "spot",
						{
							length = 300,
							angle = { "up", "down" },
							{
								type = "spot",
								link = true
							}
						}	
					}
				}	
				
			
		},
		[2] = {
				{
					length = 700,
					angle = "forward",
					{
						type = "spot",
						{
							length = 300,
							angle = { "up", "down" },
							{
								{
									length = 500,
									angle = "forward",
									{
										type = "spot",
										link = true
									}
								}
							},
							{
								length = 500,
								angle = "forward",
								{
									type = "spot",
									link = true
								}
							}
						}	
					}	
						
				},
				
			
		},
		[3] = {
				{
					length = 700,
					angle = "forward",
					{
						type = "spot",
						{
							length = 300,
							angle = "up",
							{
								{
									length = 500,
									angle = "forward",
									{
										type = "spot",
										link = true
									}
								}
							},
							{
								length = 500,
								angle = "forward",
								{
									type = "spot",
									link = true
								}
							}
						},
						{
							length = 300,
							angle = { "up", "down" },
							{
								{
									length = 500,
									angle = "forward",
									{
										type = "spot",
										link = true
									}
								}
							},
							{
								length = 500,
								angle = "forward",
								{
									type = "spot",
									link = true
								}
							}
						}	
					}	
				}
			
			}
		
	
	}