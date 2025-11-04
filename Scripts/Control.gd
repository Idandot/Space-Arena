extends Panel

var colors = {
	"Base": Color.WHITE,
	"Warning": Color.ORANGE,
	"Critical": Color.RED
}


func _ready():
	BattleEventManager.connect("log_signal", Callable(self, "_on_log"))

func _on_log(msg, color_name):
	$"Battle Log".push_color(colors[color_name])
	$"Battle Log".add_text(msg + "\n")
	$"Battle Log".pop()
