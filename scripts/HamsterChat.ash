void main (string sender , string message, string channel){
   if (channel == "/hobopolis"){
      if (contains_text(message, "has taken the stage")){
         int people_staged = to_int(get_property("people_staged"));
         people_staged += 1;
         set_property("people_staged" , people_staged);
      }
      if (contains_text(message, "got a mosh pit going")){
         set_property("moshed" , "true");
      }
      if (contains_text(message, "off stage")){
         int people_unstaged = to_int(get_property("people_unstaged"));
         people_unstaged += 1;
         set_property("people_unstaged" , people_unstaged);
      }
      if (contains_text(message, "update")){
         cli_execute("git update Hamster");
      }
      if (my_id() == "2017820" && contains_text(message, "Grendel")){
         cli_execute("abort");
         cli_execute("Hamster.ash");
      }
      if (my_id() == "2813285" && contains_text(message, "Grendel")){
         print("success");
      }
   }
}
