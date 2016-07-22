require 'rubygems'
require 'pushmeup'
GCM.host = 'https://android.googleapis.com/gcm/send'
GCM.format = :json
GCM.key = "AIzaSyBUhVPJ2-i_ae6HDihsjCzHMHWdeCrHS6c"
destination = ["APA91bFOtOXXF6nbzdPDbESlDqrnH5nyr3gONb5BhNXjNFghVY_3eYxd0eKpzXlkbAFZ5y-bOZ9xfq2dSwckXhg0jaAlDuuCpHsHExyHGXysPoXhkQVaRXDtkUJDq0md7pixCSfaTKBJTEJ1Ewf751vCQz8ghDg_OwBwMMoVwMZfvXopUmfK2th9sXuWlR4HNpG6-zdKPVMj"]
data = {:message => "Telerik AppBuilder ftw!", :msgcnt => "1"}

GCM.send_notification( destination, data)
