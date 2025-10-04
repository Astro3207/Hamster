void main (string sender , string message, string channel){
   if (channel == "/hobopolis"){
      if (contains_text(message, "has taken the stage")){
         int people_staged = to_int(get_property("people_staged"));
         people_staged += 1;
         set_property("people_staged" , people_staged);
      }
      if (contains_text(message, "has left the stage")){
         int people_staged = to_int(get_property("people_staged"));
         people_staged -= 1;
         set_property("people_staged" , people_staged);
      }
      if (contains_text(message, "got a mosh pit going")){
         set_property("moshed" , "true");
      }
      if (contains_text(message, "offstage")){
         int people_unstaged = to_int(get_property("people_unstaged"));
         people_unstaged += 1;
         set_property("people_unstaged" , people_unstaged);
      }
   }
}
