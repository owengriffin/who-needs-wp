
This is a test blog post.

I am now going to attempt some code highlighting...

@@@ ruby
# A rack app
proc {
  [200, { 'Location' => '/' },
  "You are being redirected to /"
  ]
}
@@@

## Some JavaScript

@@@ javascript
function countdown() {
  var i = 10;
  while(i--) { alert(i); }
}
@@@