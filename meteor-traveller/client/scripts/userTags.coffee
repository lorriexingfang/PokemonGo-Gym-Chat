root = exports ? this
root.userTags = [
  {
    name: '吃货'
    image: '/localservice/user_tag_1.png'
  },
  {
    name: '俱乐部'
    image: '/localservice/user_tag_2.png'
  },
  {
    name: '客栈'
    image: '/localservice/user_tag_3.png'
  },
  {
    name: '旅游达人'
    image: '/localservice/user_tag_4.png'
  }
]
root.findImageByName = (name)->
  for item in userTags
      if item.name is name
        return item.image
    ''