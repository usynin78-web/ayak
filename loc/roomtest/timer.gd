extends Label  

var time_passed := 0.0

func _process(delta: float) -> void:  
 time_passed += delta

 var total_seconds := int(time_passed)  
 var hours := total_seconds / 3600  
 var minutes := (total_seconds % 3600) / 60  
 var seconds := total_seconds % 60  

 text = "Время %02d:%02d:%02d" % [hours, minutes, seconds]
