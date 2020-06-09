import { LocalizationService, Players, RunService } from "@rbxts/services"

let Translate: (key: string, args: Map<string, string | number>) => string

const DEFAULT_LOCALE = "en-us"

if (RunService.IsRunning()) {
	if (RunService.IsServer()) {
		Translate = (key: string) => {
			error(`Trying to translate ${key} from the server`)
		}
	} else {
		const translator = LocalizationService.GetTranslatorForPlayerAsync(Players.LocalPlayer)
		let backupTranslator: Translator | undefined
		if (translator.LocaleId !== DEFAULT_LOCALE) {
			print(`Player is using a non English locale: ${translator.LocaleId}`)
			backupTranslator = LocalizationService.GetTranslatorForLocaleAsync(DEFAULT_LOCALE)
		}

		const alreadyWarned = new Set()

		function translate(
			key: string,
			args: Map<string, string | number>,
			translator: Translator,
			onTranslationMissing: () => string,
		): string {
			let message = key

			const [success, problem] = pcall(() => {
				message = translator.FormatByKey(key, args)
			})

			if (!success) {
				if ((problem as string).match("not found in any active")[0]) {
					return onTranslationMissing()
				} else {
					warn(`Couldn't translate ${key}: ${problem}`)
				}
			}

			return message
		}

		Translate = (key, args) => {
			let message = key

			if (!alreadyWarned.has(key)) {
				function onSourceError(): string {
					warn(`Translation missing for ${key}!`)
					alreadyWarned.add(key)
					return key
				}

				message = translate(
					key,
					args,
					translator,
					() => {
						if (backupTranslator) {
							return translate(
								key,
								args,
								backupTranslator,
								onSourceError,
							)
						} else {
							return onSourceError()
						}
					},
				)
			}

			return message
		}
	}
} else {
	Translate = (key: string) => {
		return key
	}
}

export = Translate
