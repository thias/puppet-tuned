class tuned::error (
  $errormsg = undef,
){
  case $errormsg {
    # notify will log an error in the client output but continue on.
    'WrongOs' : { notify{'WrongOS':message=>"Module ${module_name} is not supported on ${::operatingsystem}", } }
    'WrongVariation' : { notify{'WrongVariation':message=>"Module ${module_name} does not support the ${::operatingsystem} variation.", } }
    'WrongVersion' : { notify{'WrongVersion':message=>"Module ${module_name} does not support this version of ${::operatingsystem}.", } }
    # fail will log an error and stop the client from continuing.
    default : { fail("Module ${module_name} name has failed for unknown reasons.") }
  }
}

