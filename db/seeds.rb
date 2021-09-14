def update_or_create_site(id, attributes)
  Site.where(internal_name: id).update_or_create(attributes).save
end

update_or_create_site("twitter", {
  display_name: "Twitter",
  homepage: "https://twitter.com",
  artist_url_templates: ["twitter.com/{site_artist_identifier}"],
  artist_identifier_regex: "[a-zA-Z0-9_]{1,15}",
  artist_submission_template: "https://twitter.com/{site_artist_identifier}/status/{site_submission_identifier}/",
})

update_or_create_site("furaffinity", {
  display_name: "FurAffinity",
  homepage: "https://www.furaffinity.net",
  artist_url_templates: ["furaffinity.net/user/{site_artist_identifier}"],
  artist_identifier_regex: "[a-zA-Z0-9_\-~\.]{1,30}",
  artist_submission_template: "https://www.furaffinity.net/view/{site_submission_identifier}/",
})

update_or_create_site("inkbunny", {
  display_name: "Inkbunny",
  homepage: "https://inkbunny.net",
  artist_url_templates: ["inkbunny.net/{site_artist_identifier}"],
  artist_identifier_regex: "[a-zA-Z0-9]{1,22}",
  artist_submission_template: "https://inkbunny.net/s/{site_submission_identifier}/",
})

update_or_create_site("sofurry", {
  display_name: "Sofurry",
  homepage: "https://www.sofurry.com",
  artist_url_templates: ["{site_artist_identifier}.sofurry.com"],
  artist_identifier_regex: "[a-zA-Z0-9_\-]{1,25}",
  artist_submission_template: "https://www.sofurry.com/view/{site_submission_identifier}/",
})

update_or_create_site("deviantart", {
  display_name: "DeviantArt",
  homepage: "https://www.deviantart.com",
  artist_url_templates: [
    "deviantart.com/{site_artist_identifier}",
    "{site_artist_identifier}.deviantart.com",
  ],
  artist_identifier_regex: "[a-zA-Z0-9]{1,20}",
  artist_submission_template: "https://www.deviantart.com/{site_artist_identifier}/art/{site_submission_identifier}/",
})

update_or_create_site("artstation", {
  display_name: "ArtStation",
  homepage: "https://www.artstation.com",
  artist_url_templates: ["artstation.com/{site_artist_identifier}"],
  artist_identifier_regex: "[a-zA-Z0-9_\-]{3,63}",
  artist_submission_template: "https://www.artstation.com/artwork/{site_submission_identifier}/",
})

update_or_create_site("patreon", {
  display_name: "Patreon",
  homepage: "https://www.patreon.com",
  artist_url_templates: ["patreon.com/{site_artist_identifier}"],
  artist_identifier_regex: "[a-zA-Z0-9_]{1,64}",
  artist_submission_template: "https://www.patreon.com/posts/{site_submission_identifier}/",
})

update_or_create_site("pixiv", {
  display_name: "Pixiv",
  homepage: "https://www.pixiv.net",
  artist_url_templates: [
    "pixiv.net/users/{site_artist_identifier}",
    "pixiv.net/member.php?id={site_artist_identifier}/",
  ],
  artist_identifier_regex: "[0-9]{1,8}",
  artist_submission_template: "https://www.pixiv.net/artworks/{site_submission_identifier}/",
})

update_or_create_site("weasyl", {
  display_name: "Weasyl",
  homepage: "https://www.weasyl.com",
  artist_url_templates: [
    "weasyl.com/~{site_artist_identifier}",
    "weasyl.com/profile/{site_artist_identifier}",
  ],
  artist_identifier_regex: "[a-zA-Z0-9]{1,25}",
  artist_submission_template: "https://www.weasyl.com/~{site_artist_identifier}/submissions/{site_submission_identifier}/",
})

update_or_create_site("tumblr", {
  display_name: "Tumblr",
  homepage: "https://www.tumblr.com",
  artist_url_templates: ["{site_artist_identifier}.tumblr.com"],
  artist_identifier_regex: "[a-zA-Z0-9]{1,32}",
  artist_submission_template: "https://{site_artist_identifier}.tumblr.com/post/{site_submission_identifier}/",
})

update_or_create_site("reddit", {
  display_name: "Reddit",
  homepage: "https://www.reddit.com",
  artist_url_templates: [
    "{reddit_old_new}reddit.com/user/{site_artist_identifier}",
    "{reddit_old_new}reddit.com/u/{site_artist_identifier}",
  ],
  artist_identifier_regex: "[a-zA-Z0-9_\-]{3,20}",
  artist_submission_template: "https://redd.it/{site_submission_identifier}/",
})

update_or_create_site("newsground", {
  display_name: "Newsground",
  homepage: "https://www.newgrounds.com",
  artist_url_templates: ["{site_artist_identifier}.newgrounds.com"],
  artist_identifier_regex: "[a-zA-Z0-9~]{1,20}",
  artist_submission_template: "https://www.newgrounds.com/art/view/{site_artist_identifier}/{site_submission_identifier}/",
})

update_or_create_site("vkontakte", {
  display_name: "VK",
  homepage: "https://vk.com",
  artist_url_templates: ["vk.com/{site_artist_identifier}"],
  artist_identifier_regex: "[a-zA-Z0-9_]{1,26}",
  artist_submission_template: "https://vk.com/{site_artist_identifier}?z=photo-{site_submission_identifier}/",
})

update_or_create_site("instagram", {
  display_name: "Instagram",
  homepage: "https://www.instagram.com",
  artist_url_templates: ["instagram.com/{site_artist_identifier}"],
  artist_identifier_regex: "[a-zA-Z0-9_\.]{1,30}",
  artist_submission_template: "https://www.instagram.com/p/{site_submission_identifier}/",
})
