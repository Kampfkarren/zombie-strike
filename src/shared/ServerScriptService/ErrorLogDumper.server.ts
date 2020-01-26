import { HttpService, LogService, Players, ReplicatedStorage } from "@rbxts/services"

const LOG_DELAY = 60
const URL = "CENSORED URL

let lastLogSent = 0

Players.PlayerAdded.Connect((player) => {
	player.Chatted.Connect((message) => {
		if (message === "/sendlogs") {
			let message

			if (tick() - lastLogSent <= LOG_DELAY) {
				message = "Sent too recently."
			} else {
				lastLogSent = tick()
				const result = pcall(() => {
					return HttpService.PostAsync(URL, "serverLog=" + HttpService.UrlEncode(
						HttpService.JSONEncode(LogService.GetLogHistory())
					), Enum.HttpContentType.ApplicationUrlEncoded, true)
				})

				if (result[0]) {
					const data = HttpService.JSONDecode(result[1]) as {
						uuid: string
					}

					message = `GIVE THIS CODE TO KAMPFKARREN: ${data.uuid}`
				} else {
					message = `Couldn't submit logs: ${result[1]}`
				}
			}

			ReplicatedStorage.Remotes.SendServerLogs.FireClient(player, message)
		}
	})
})
