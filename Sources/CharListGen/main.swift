import Foundation

//  Characters are stored in the `chars` array.
//  Each character is itself an array of codepoints.
//  Codepoints are stored as `UInt32` (ie, UTF-32).
var chars: [[UInt32]] = [[]]
chars.reserveCapacity(0xFFFF)

//  A line begins with a codepoint if it matches this regular
//    expression.
//  This regex only selects hex numbers in the range 0 to 10FFFF, with
//    any number of leading zeros.
let beginsWithCodepoint = try! NSRegularExpression(
	pattern: "^(?:U+)?0*((?:10|[1-9A-Fa-f])?[0-9A-Fa-f]{1,4})"
)

//  `largestCharacter` stores the largest number of codepoints to
//    appear in a character.
//  This is used to ensure all characters are padded to the same number
//    of codepoints.
var largestCharacter = 1

//  `readyForNewCharacter` tells the code to create a new character
//    rather than append to the previous one.
var readyForNewCharacter = true

//  Reads in lines from STDIN to gather characters.
while let line = readLine() {

	//  If the line starts with a codepoint, this will get the range
	//    it covers.
	if let codepointRange = beginsWithCodepoint.firstMatch(
		in: line, range: NSRange(
			location: 0,
			length: line.count < 6 ? line.count : 6
		)
	)?.range(at: 1) {

		//  Getting the actual codepoint is a little tricky because
		//    `NSRange` is not the same thing as a `Range<String>`.
		if let codepoint = UInt32(
			line[line.startIndex..<line.index(
				line.startIndex,
				offsetBy: codepointRange.length
			)],
			radix: 16
		) {

			//  If it is time for a new character, it needs to be
			//    created.
			if readyForNewCharacter {
				chars.append([])
				readyForNewCharacter = false
			}

			//  The codepoint is added to the last character in
			//    `chars`.
			chars[chars.count - 1].append(codepoint)

			//  If the length of this character is bigger than
			//    `largestCharacter`, we have a new largest size.
			if chars.last!.count > largestCharacter {
				largestCharacter = chars.last!.count
			}

		//  If the codepoint couldn't be gotten, it's as if the
		//    regular expression didn't match.
		} else {
			readyForNewCharacter = true
		}

	//  If there is no codepoint, then the current character is done.
	} else if chars.last!.count > 0 {
		readyForNewCharacter = true
	}
}

//  The current position within the current line of data is stored in
//    `charInLine`.
//  Positions range from 1 to 16.
var charInLine = 1

//  The data which will be written to file is stored in `outputData`.
var outputData = Data()

//  This function appends a padded character to the output data.
func appendToOutputData(character: String) {

	//  Appends the UTF-8 form of the character.
	outputData.append(contentsOf: character.utf8)

	//  If this is the last character in the line, it needs to be
	//    terminated by U+000D CARRIAGE RETURN, U+000A LINE FEED.
	if charInLine == 16 {
		outputData.append(contentsOf: ("\r\n" as String).utf8)
	}

	//  Advances to the next position in the line.
	charInLine = charInLine % 16 + 1
}

//  Iterates over each character to create data.
for char in chars {

	//  The string form of the character is decoded from its
	//    codepoints as UTF-32.
	var charString = String(decoding: char, as: Unicode.UTF32.self)

	//  U+0000 NULL characters need to be appended if the size of the
	//    character is less than that of the largest.
	if char.count < largestCharacter {
		charString.append(
			String(
				repeating: "\0",
				count: largestCharacter - char.count
			)
		)
	}

	//  Appends the character to the data.
	appendToOutputData(character: charString)
}

//  If the final line was not finished, it needs to be padded with
//    U+0000 NULL characters.
while charInLine != 1 {
	appendToOutputData(
		character: String(repeating: "\0", count: largestCharacter)
	)
}

//  The filename is taken from the command line arguments, and defaults
//    to "charlist".
let filename = CommandLine.arguments.count > 1 ?
	CommandLine.arguments[1] : "charlist"

//  The file is written to the current working directory.
let fileURL = URL(
	fileURLWithPath: FileManager.default.currentDirectoryPath,
	isDirectory: true
).appendingPathComponent(filename, isDirectory: false)

//  Writes the file.
do {
	try outputData.write(to: fileURL)
} catch {
	print("Failed to write file.")
}
