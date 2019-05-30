
class Shop
	def register_test_data
		pp! register_article Shop::Article.from_json %<{
			"name":  "夕立",
			"price": 666.66,
			"description": "Uncontested best grill. Will wreck your enemies during both day and night battle.",
			"category": "shiratsuyu",
			"images": [
				"https://cdn41.picsart.com/170296069000202.jpeg?c256x256",
				"https://vignette.wikia.nocookie.net/kancolle/images/a/ae/Yuudachi_Kai_Ni_New_Year%27s_Full.png/revision/latest/scale-to-width-down/300?cb=20141231190132",
				"https://vignette.wikia.nocookie.net/kancolle/images/b/bc/Yuudachi_Kai_Ni_Full.png/revision/latest/scale-to-width-down/300?cb=20181029142944"
			]
		}>

		pp! register_article Shop::Article.from_json %{{
			"name":  "Shiratsuyu",
			"price": 666.66,
			"description": "Is the first ship of her class. Yes, the *first* ship!",
			"category": "shiratsuyu",
			"images": [
				"https://vignette.wikia.nocookie.net/kancolle/images/c/c8/F283173ff237e809bb3b7db29846b15562c21632v2_hq.jpg/revision/latest?cb=20180713214052"
			]
		}}

		pp! register_article Shop::Article.from_json %{{
			"name":  "Shigure",
			"price": 666.66,
			"category": "shiratsuyu",
			"description": "Likes the rain and dislikes night battles.\\n\\n…\\n\\nYes, I know, a destroyer who dislikes night battles… it makes no sense, right?"
		}}

		pp! register_article Shop::Article.from_json %{{
			"name":  "Murasame",
			"category": "shiratsuyu",
			"price": 666.66
		}}

		pp! register_article Shop::Article.from_json %{{
			"name":  "Harusame",
			"price": 666.66,
			"category": "shiratsuyu",
			"description": "The cutest of them all. Has never seen much combat, however. Good for carrying supplies around though."
		}}

		pp! register_article Shop::Article.from_json %{{
			"name":  "Kawakaze",
			"price": 666.66,
			"category": "shiratsuyu",
			"description": "Looks crazy. Sounds crazy. Probably *is* crazy."
		}}

		pp! register_article Shop::Article.from_json %{{
			"name":  "Umikaze",
			"category": "shiratsuyu",
			"price": 666.66
		}}

		pp! register_article Shop::Article.from_json %{{
			"name":  "Yamakaze",
			"price": 666.66,
			"category": "shiratsuyu",
			"description": "Mountain wind? Weird name for a weird ship daze~"
		}}

		pp! register_article Shop::Article.from_json %{{
			"name":  "Shimakaze",
			"price": 9812.13,
			"description": "Is fast and has cute 12.7cm turret-chans."
		}}

		50.times do |i|
			pp! register_article Shop::Article.from_json %{{
				"name":  "Random<#{i}>",
				"price": 9812.13,
				"description": "The article n°#{i} in the list of 50 random articles.",
				"category": "Random"
			}}
		end

		puts "WARNING: Adding lots of new, random articles for testing purposes"
		10000.times do |i|
			n = Random.rand 5

			register_article Shop::Article.from_json %{{
				"name":  "Random<#{n},#{i}>",
				"price": 9812.13,
				"description": "The article n°#{i} in the list of 10 000 random articles.",
				"category": "Random #{n}"
			}}
		end
	end
end

