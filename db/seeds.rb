def update_or_create_site(id, attributes)
  Site.where(internal_name: id).update_or_create(attributes).save
end

update_or_create_site("twitter", {
  display_name: "Twitter",
  homepage: "https://twitter.com",
  artist_url_format: "https://twitter.com/%<site_artist_identifier>s",
  artist_submission_format: "https://twitter.com/%<site_artist_identifier>s/status/%<site_submission_identifier>s",
})

update_or_create_site("furaffinity", {
  display_name: "FurAffinity",
  homepage: "https://www.furaffinity.net",
  artist_url_format: "https://www.furaffinity.net/user/%<site_artist_identifier>s",
  artist_submission_format: "https://www.furaffinity.net/view/%<site_submission_identifier>s",
})

update_or_create_site("inkbunny", {
  display_name: "Inkbunny",
  homepage: "https://inkbunny.net",
  artist_url_format: "https://inkbunny.net/%<site_artist_identifier>s",
  artist_submission_format: "https://inkbunny.net/s/%<site_submission_identifier>s",
})

update_or_create_site("sofurry", {
  display_name: "Sofurry",
  homepage: "https://www.sofurry.com",
  artist_url_format: "https://%<site_artist_identifier>s.sofurry.com",
  artist_submission_format: "https://www.sofurry.com/view/%<site_submission_identifier>s",
})

update_or_create_site("deviantart", {
  display_name: "DeviantArt",
  homepage: "https://www.deviantart.com",
  artist_url_format: "https://www.deviantart.com/%<site_artist_identifier>s",
  artist_submission_format: "https://www.deviantart.com/%<site_artist_identifier>s/art/%<site_submission_identifier>s",
})

update_or_create_site("artstation", {
  display_name: "ArtStation",
  homepage: "https://www.artstation.com",
  artist_url_format: "https://www.artstation.com/%<site_artist_identifier>s",
  artist_submission_format: "https://www.artstation.com/artwork/%<site_submission_identifier>s",
})

update_or_create_site("patreon", {
  display_name: "Patreon",
  homepage: "https://www.patreon.com",
  artist_url_format: "https://www.patreon.com/%<site_artist_identifier>s",
  artist_submission_format: "https://www.patreon.com/posts/%<site_submission_identifier>s",
})

update_or_create_site("pixiv", {
  display_name: "Pixiv",
  homepage: "https://www.pixiv.net",
  artist_url_format: "https://www.pixiv.net/users/%<site_artist_identifier>s",
  artist_submission_format: "https://www.pixiv.net/artworks/%<site_submission_identifier>s",
})

update_or_create_site("weasyl", {
  display_name: "Weasyl",
  homepage: "https://www.weasyl.com",
  artist_url_format: "https://www.weasyl.com/~%<site_artist_identifier>s",
  artist_submission_format: "https://www.weasyl.com/~%<site_artist_identifier>s/submissions/%<site_submission_identifier>s",
})

update_or_create_site("tumblr", {
  display_name: "Tumblr",
  homepage: "https://www.tumblr.com",
  artist_url_format: "https://%<site_artist_identifier>s.tumblr.com",
  artist_submission_format: "https://%<site_artist_identifier>s.tumblr.com/post/%<site_submission_identifier>s",
})

update_or_create_site("reddit", {
  display_name: "Reddit",
  homepage: "https://www.reddit.com",
  artist_url_format: "https://www.reddit.com/user/%<site_artist_identifier>s",
  artist_submission_format: "https://redd.it/%<site_submission_identifier>s",
})

update_or_create_site("newsground", {
  display_name: "Newsground",
  homepage: "https://www.newgrounds.com",
  artist_url_format: "https://%<site_artist_identifier>s.newgrounds.com",
  artist_submission_format: "https://www.newgrounds.com/art/view/%<site_artist_identifier>s/%<site_submission_identifier>s",
})

update_or_create_site("vkontakte", {
  display_name: "VK",
  homepage: "https://vk.com",
  artist_url_format: "https://vk.com/%<site_artist_identifier>s",
  artist_submission_format: "https://vk.com/%<site_artist_identifier>s?z=photo-%<site_submission_identifier>s",
})

update_or_create_site("instagram", {
  display_name: "Instagram",
  homepage: "https://www.instagram.com",
  artist_url_format: "https://www.instagram.com/%<site_artist_identifier>s",
  artist_submission_format: "https://www.instagram.com/p/%<site_submission_identifier>s",
})
