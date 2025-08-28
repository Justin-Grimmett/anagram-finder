// ... TODO
// 1. Fix button positions - eg floating Refresh
// 2. Create a common Modal - to be used for popup display - eg including the output
// 3. Add the "copyright" for the Word data
// 4. Add details of the tech stack that runs the site - because the point of this is just to be a demo on Git etc

// https://www.perplexity.ai/search/create-a-react-front-end-web-f-9DDpRBmiSJqq.WxJeFhj2w#1

import React, { useRef , useState, useEffect } from "react";

export default function LetterInput() {
	const [lettersEntered , setLettersEntered] = useState<string>("");		// The main input data String - eg the letters entered by the user
	const inputRef = useRef(null);											// Used for functionality of the input text field

	// An example of how React "States" work - "useState hook"
	const [submitLabelText, setSubmitLabelText] = useState<string>("");
	// submitLabelText 		= the variable - eg a string
	// setSubmitLabelText 	= the automated function which populates the variable
	// "" 					= the default value to be used

	// Used to send data to the API for backend processing
	const [outputJson , setOutputJson] = useState<{}>({});

	// The backend processed data returned from the API
	const [returnedJsonWordData , setReturnedJsonWordData] = useState<{}>({});
	// Has the Submit button been clicked by the user?
	const [submitIsClicked, setSubmitIsClicked] = useState<boolean>(false);

	// "Icons" unicode characters
	const backSpaceIcon : string = "⌫";
	const clearIcon : string = "⮾";

	// All alphabet letters
	const allowedLetters : string[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
	allowedLetters.push(backSpaceIcon);

	// Minimum required number of characters
	const minRequiredLength : number = 4;
	// Maximum allowed number of characters
	const maxAllowedLength : number = 9;

	// For the current selection of the text field
	let inputFieldData : any = null
	let startSelectionIdx : number = 0
	let endSelectionIdx : number = 0

	// Store the timestamp of when the page is first opened - to be used potentially for reference/comparison later on
	const [pageRefreshTimeStamp, setPageRefreshTimeStamp] = useState<Date>(new Date());
	const [submitTimeStamp, setSubmitTimeStamp] = useState<Date>(new Date());	// Note this data should be empty at this point, so the default is irrelevant
	const [returnTimeStamp, setReturnTimeStamp] = useState<Date>(new Date());	// Note this data should be empty at this point, so the default is irrelevant

	// Store the buttons pressed by the user - for backend reference
	const [buttonsPressed, setButtonsPressed] = useState<string[]>([]);
	// Append this array with the button pressed
	const addButtonPressed = (button : string) => {
		setButtonsPressed(buttonsPressed => [...buttonsPressed, button]);
	};

	// For User Agent data - eg browser version and OS - note will Not work in Mobile Native Apps (maybe use something like react-native-device-info for that specifically)
	const [userAgent, setUserAgent] = useState("");

	// Functionality inside this will only be run once - eg on first load
	useEffect(() => {
		function testRunOnlyOnce () {
			// Example function contents
		}
		
		setPageRefreshTimeStamp(new Date());

		testRunOnlyOnce();	// Run the above example function, which would only be run one time

		setUserAgent(window.navigator.userAgent);
	}, []);

	// When English letter buttons are clicked with mouse (or finger on touchscreen?)
	const handleLetterClick = (letterClicked : string) => {
		// Allow for backspace button to manually delete one character
		if (letterClicked === backSpaceIcon) {
			if (lettersEntered.length > 0) {
				setSelection();
				// Delete the relevant single Letter where the cursor is (or at end by default)
				let isMultiSelect : number = endSelectionIdx > startSelectionIdx ? 0 : 1;
				const newTextValue = lettersEntered.slice(0, startSelectionIdx-isMultiSelect) + lettersEntered.slice(endSelectionIdx);
				setLettersEntered(newTextValue);
			}
			logButtonPress("Backspace");
		// Otherwise one of the A-Z letter buttons
		} else {
			// Existing text must be shorter than the maximum allowed length
			if (lettersEntered.length < maxAllowedLength) {
				// Run the function to add the letter clicked
				updateText(letterClicked, true);
			}
			logButtonPress(letterClicked);
		}
		handleMsg();
	};

	// When text is typed manually into the text field directly
	const handleChange = (textField : any) => {
		// Existing text must be shorter than the maximum allowed length
		if (textField.target.value.length <= maxAllowedLength) {
			// Run the function to add the typed letter
			setLettersEntered(textField.target.value);
		}
		handleMsg();
	};

	// Boolean: disable all letter buttons when max length reached
	const disableLettersIfMaxLen = lettersEntered.length >= maxAllowedLength;

	// When to disable the Letter buttons so they cannot be clicked anymore
	const runDisableLetters = (letterClicked : string) => {
		// Backspace button should always be active
		if (letterClicked === backSpaceIcon) {
			return !textExists();
		} else {
			// Return the controlling boolean
			return disableLettersIfMaxLen;
		}
	};

	// Fully clear the text field contents
	const clearText = () => {
		setLettersEntered("");		// Clear the text variable
		setSubmitLabelText("");
		logButtonPress("Clear");
	}

	// For the string formatting of the "buttons" pressed (eg as opposed to typing letters manually)
	const logButtonPress = (buttonText : string) => {
		addButtonPressed(formatButtonPress(buttonText));
	}
	const formatButtonPress = (buttonText : string):string => {
		return `[ ${buttonText} ]`;
	}

	// Handler for manually typing text into the entry field
	const handleKeyDown = (keyPressed : any) => {
		addButtonPressed(keyPressed.key.toString());

		// If maximum allowed letter is reached, do not continue
		if (disableLettersIfMaxLen) return;

		// Get the pressed key
		const keyName : string = keyPressed.key;

		// Allow modifier keys and shortcuts like Ctrl+A, Cmd+C, etc.
		// Also check for specific Keys
		if (keyPressed.ctrlKey || keyPressed.metaKey || keyPressed.altKey || ["ArrowLeft" , "ArrowRight" , "Home" , "End" , "Delete" , "Backspace"].includes(keyName) ) {
			// Allow default behavior for shortcuts
			return;
		}

		// Check if the key is a single English letter (case insensitive)
		if (/^[a-zA-Z]$/.test(keyName)) {
			// Run function to update text based on the letter typed
			updateText(keyName, false);
			
			// Prevent default so the character does not get added by the browser as well
			keyPressed.preventDefault();
		} else {
			// For all other characters/keys do not do anything
			keyPressed.preventDefault();
		}
	};

	// Functionality to actually update the text displayed in the entry field
	const updateText = (letter : string, buttonPress : boolean) => {
		// Get the selection range - relevant if the cursor is manually clicked into the field, not at the end
		setSelection();

		// Insert letter at cursor position
		const newTextValue = lettersEntered.slice(0, startSelectionIdx) + String(letter).toUpperCase() + lettersEntered.slice(endSelectionIdx);
		setLettersEntered(newTextValue);

		// Set caret just after inserted char
		requestAnimationFrame(() => {
			if (buttonPress === true) {
				cursorAtEnd();
			} else {
				// Otherwise update the caret by one
				inputFieldData.selectionStart = inputFieldData.selectionEnd = startSelectionIdx + 1;
			}
		});
	}

	// Set the cursor selection of the text field
	const setSelection = () => {
		inputFieldData = inputRef.current;
		startSelectionIdx = inputFieldData.selectionStart;
		endSelectionIdx = inputFieldData.selectionEnd;
	}

	// Set the cursor caret to be at the very end of the text field
	const cursorAtEnd = () => {
		// If the letter is added from one of the Buttons, move the cursor to the very end
		inputFieldData.selectionStart = lettersEntered.length + 1;
		inputFieldData.selectionEnd = lettersEntered.length + 1;
	}

	// Does the text field contain any text?
	const textExists = () => {
		return lettersEntered.length > 0;
	}

	// Handles the dyanmic label message
	const handleMsg = () => {
		let labelMsg = '\u2800';	// Space-preserving invisible char
		if (disableLettersIfMaxLen) {
			labelMsg = `Maximum allowed length (${maxAllowedLength}) reached`
		} else if (lettersEntered.length > 0) {
			labelMsg = `[ ${lettersEntered.length} ]`;
		}

		return labelMsg;
	}

	// Submit button has been clicked
	const doSubmit = () => {
		// Manually add to the log of buttons pressed - due to state updates being asynchronous and batched this was not being included
		let finalButtonArray : string[] = [...buttonsPressed , formatButtonPress("Submit")];
		setButtonsPressed(finalButtonArray);
		
		// Send "text" variable to the API to do backend work, and then return the output from that here
		// ...

		// Used for timestamp comparison
		let submitTime : Date = new Date();
		setSubmitTimeStamp(submitTime);
		let timeDiffInSecs : number = (submitTime.getTime() - pageRefreshTimeStamp.getTime()) / 1000;

		// Generate a UUID - just in case its required for data reference purposes
		let uuid: string = crypto.randomUUID();

		// The "state" auto function to set the value of submitLabelText variable
		// Currently for Testing only
		// Eventually the full output from the API will be displayed here in some form
		setSubmitLabelText(`"${lettersEntered}" will be sent to the API \n ${timeDiffInSecs} seconds between page Load and Submit \n Buttons pressed: { ${finalButtonArray} } \n User Agent : ${userAgent}`);
		
		// Use this JSON data to pass over to the API to be used in the backend
		setOutputJson( {
			"letters" : lettersEntered
			, "user-agent" : userAgent
			, "buttons-clicked" : finalButtonArray
			, "uuid" : uuid
			, "utc-timestamp-page-load" : formatTimeString(pageRefreshTimeStamp)
			, "utc-timestamp-submit" : formatTimeString(submitTimeStamp)
			, "tz-offset-submit" : submitTimeStamp.getTimezoneOffset()
		});

		setSubmitIsClicked(true);
	}

	// Submitting the data to the backend API asynchronously
	useEffect(() => {
		// PUT request using fetch with async/await
		async function runApiPost () {
			const requestOptions : RequestInit = {
				method: 'PUT',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify(outputJson), 
				mode: 'cors'
			};
			
			// While doing AWS Testing this will need to be dynamically updated everytime Terraform etc is run
			let uniqueAwsApiId : string = "2xrs7l44rf";

			const response = await fetch(`https://${uniqueAwsApiId}.execute-api.ap-southeast-2.amazonaws.com/anagram`, requestOptions);
			const data = await response.json();
			
			// Just used for Testing - Remove this once all the necessary data is used as needed
			console.log(data);

			setReturnedJsonWordData(data);		

			setSubmitIsClicked(false);

			setReturnTimeStamp(new Date());
		}

		if (submitIsClicked) {
			runApiPost();
		}
	}, [outputJson, returnedJsonWordData, submitIsClicked, submitLabelText]);

	// What this "useEffect" means is this will run when the variable "returnedJsonWordData" changes (and others in the same place) - and this would only occur on the Async API call
	// This is just used to display the Returned data in the frontend - remove once this is display correctly - eg in a modal
	useEffect(() => {
		if (returnedJsonWordData) {
			if (Object.keys(returnedJsonWordData).length > 0) {
				if ("wordData" in returnedJsonWordData) {
					// "prev" is what it already includes
					let timeDiffInSecs : number = (returnTimeStamp.getTime() - submitTimeStamp.getTime()) / 1000;
					setSubmitLabelText(prev => prev + "\n Returned data : \n" + JSON.stringify(returnedJsonWordData["wordData"]).replaceAll('","','" , "') + `\nData returned in ${timeDiffInSecs} seconds`);
				}
			}
		}
	}, [returnedJsonWordData, returnTimeStamp, submitTimeStamp]);

	// Format a DateTime in the common string format
	const formatTimeString = (date : Date) : string => {
		return (`${padZeros(date.getUTCFullYear(),4)}-${padZeros(date.getUTCMonth()+1,2)}-${padZeros(date.getUTCDate(),2)} ${padZeros(date.getUTCHours(),2)}:`
			+ `${padZeros(date.getUTCMinutes(),2)}:${padZeros(date.getUTCSeconds(),2)}.${padZeros(date.getUTCMilliseconds(),3)}`).trim();
	}

	// Pad a numeric string with a certain character up to a certain length - eg zeros at the start of a value for a time format
	const padZeros = (val:number, len:number=2, char:string="0"):string => {
		let str:string = val.toString().trim();
		while(str.length < len) {
			str = char + str;
		}
		return str.trim();
	}

	// Refresh the page
	const doRefresh = () => {
		window.location.reload();
	}

	// The Front-End
	// ************************************************************************************************************************
	return (
		<div style={{ fontFamily: "Arial", textAlign: "center", marginTop: "50px" }}>
			<h2>Anagram Finder</h2>
			<h3>(and possible future word game)</h3>
			<h4>{`Enter at least ${minRequiredLength} characters and press Submit`}</h4>

			{/* Top controls */}
			<div style={{ display: "flex", alignItems: "center", marginBottom: "15px" , justifyContent: "center"}}>
				{/* The input field */}
				<input
					ref={inputRef}
					type="text"
					value={lettersEntered}
					maxLength={maxAllowedLength}
					onChange={handleChange}
					style={{
						padding: "8px",
						fontSize: "18px",
						width: "300px",
						textAlign: "center"
					}}
					onKeyDown={handleKeyDown}
				/>
				{/*Clear button*/}
				<button 
					style={{
						fontSize: "20px",
						textAlign: "center",
						marginLeft: "5px",
						cursor : textExists() ? "pointer" : "not-allowed"
						
					}} 
					onClick={clearText}
					disabled = {!textExists()}
					title={"Clear All"}
				>
					{/* Text for the clear button*/}
					{clearIcon}
				</button>
			</div>
			
			<div 
				style={{marginBottom: "15px"}}
			>
				{/* The text contents of this label */}
				{handleMsg()}
			</div>
			
			{/* The letter buttons */}
			<div style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", maxWidth: "400px", margin: "0 auto" }}>
				{allowedLetters.map((eachLetter) => (
					<button
						key={eachLetter}
						title={eachLetter===backSpaceIcon ? "Backspace" : ""}
						onClick={() => handleLetterClick(eachLetter)}
						disabled={runDisableLetters(eachLetter)} // disables all relevant Letter buttons when at max length
						style={{
							margin: "3px",
							padding: "10px 15px",
							fontSize: "18px",
							cursor: runDisableLetters(eachLetter) ? "not-allowed" : "pointer",
							opacity: runDisableLetters(eachLetter) ? 0.5 : 1
						}}
					>
						{/* The dynamic Letter text displayed on the button */}
						{eachLetter}	
					</button>
				))}
			</div>
			
			<div style={{marginTop: "20px", display: "flex", justifyContent: "center"}}>
				<button
					disabled={lettersEntered.length < minRequiredLength}
					onClick={doSubmit}
					style={{
						marginTop: "20px",
						margin: "3px",
						padding: "10px 15px",
						fontSize: "18px",
						width: "200px"			// Half of the above hardcoded max-width
						, cursor : lettersEntered.length < minRequiredLength ? "not-allowed" : "pointer"
					}}
					title={"Submit"}
				>
					Submit
				</button>
			</div>
			
			{/* Button to manually refresh the page */}
			<div style={{marginTop: "20px", display: "flex", justifyContent: "center"}}>
				<button
					style={{
						marginTop: "20px",
						margin: "3px",
						padding: "10px 15px",
						fontSize: "18px",
						cursor : "pointer"
					}}
					onClick={doRefresh}
					title={"Refresh"}
				>
					⟲
				</button>
			</div>

			{/* JUST FOR TESTING - Until the API exists and the output is fully implemented etc*/}
			<div 
				style={{marginTop: "20px"}}
			>
				{/* Label contents - set by the "State" declared at the top - allow for multiple lines */}
				{submitLabelText.split("\n").map((lineText,keyData) => {
					return <div key={keyData}>{lineText}</div>;
				})}
			</div>
		</div>
	);
}
