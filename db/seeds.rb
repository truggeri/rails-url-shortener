# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

shorts = [
  ["jobs", "https://www.ziprecruiter.com/candidate/search?search=software+engineer&location=Cary%2C+NC"],
  ["dog", "https://www.petfinder.com/dog/chubbs-51756667/nc/albemarle/stanly-county-humane-society-nc399/"],
  ["art", "https://www.google.com/maps/place/North+Carolina+Museum+of+Art/@35.8112033,-78.7859331,12.64z/data=!4m5!3m4!1s0x89acf5d3536f686b:0x841b73fc133ba241!8m2!3d35.8100915!4d-78.7023275"]
]

shorts.each do |s|
  Short.create(short_url: s.first, full_url: s.second)
end
