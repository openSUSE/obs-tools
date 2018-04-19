module Sawyer
 class Resource
   # depfu creates a branch in the repository 
   # e.g. depfu/update/srcapi/rubocop-0.55.0
   # so we need to check for the head ref name
   def depfu?
     key?(:head) && head.key?(:ref) && head.ref.start_with?('depfu') 
   end
 end
end
