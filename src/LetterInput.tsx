// https://www.perplexity.ai/search/create-a-react-front-end-web-f-9DDpRBmiSJqq.WxJeFhj2w#1

import React, { useRef , useState } from "react";

export default function LetterInput() {
	const [text, setText] = useState("");
	const inputRef = useRef(null);

	// An example of how React "States" work
	const [submitLabelText, setSubmitLabelText] = useState("");
	// submitLabelText 		= the variable - eg a string
	// setSubmitLabelText 	= the automated function which populates the variable
	// "" 					= the default value to be used

	// "Icons" unicode characters
	const backSpaceIcon = "⌫";
	const clearIcon = "⮾";

	// All alphabet letters
  	const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
	letters.push(backSpaceIcon);

	// Minimum required number of characters
	const minLen = 4;
	// Maximum allowed number of characters
	const maxLength = 9;

	// For the current selection of the text field
	let input:any = null
	let start = 0
	let end = 0

  	// When English letter buttons are clicked
  	const handleLetterClick = (letter: string) => {
		// Allow for backspace button to manually delete one character
		if (letter === backSpaceIcon) {
			if (text.length > 0) {
				setSelection();
				// Delete the relevant single Letter where the cursor is (or at end by default)
				const newValue = text.slice(0, start-1) + text.slice(end);
				setText(newValue);
			}
		// Otherwise one of the A-Z letter buttons
		} else {
			// Existing text must be shorter than the maximum allowed length
			if (text.length < maxLength) {
				// Run the function to add the letter clicked
				updateText(letter, true);
			}
		}
		handleMsg();
  	};

	// When text is typed manually into the text field directly
	const handleChange = (e:any) => {
		// Existing text must be shorter than the maximum allowed length
		if (e.target.value.length <= maxLength) {
			// Run the function to add the typed letter
			setText(e.target.value);
		}
		handleMsg();
	};

	// When to disable the Letter buttons so they cannot be clicked anymore
	const runDisableLetters = (letter:string) => {
		// Backspace button should always be active
		if (letter === backSpaceIcon) {
			return !textExists();
		} else {
			// Return the controlling boolean
			return disableLetters;
		}
	};

	// Boolean: disable all letter buttons when max length reached
  	const disableLetters = text.length >= maxLength;

	// Fully clear the text field contents
	const clearText = () => {
		setText("");
		setSubmitLabelText("");
	}

	// Handler for manually typing text into the entry field
	const handleKeyDown = (e:any) => {
		// If maximum allowed letter is reached, do not continue
		if (disableLetters) return;

		// Get the pressed key
		const key = e.key;

		// Allow modifier keys and shortcuts like Ctrl+A, Cmd+C, etc.
		// Also check for specific Keys
		if (e.ctrlKey || e.metaKey || e.altKey || key === "ArrowLeft" || key === "ArrowRight" || key === "Home" || key === "End" || key === "Delete" || key === "Backspace") {
			// Allow default behavior for shortcuts
			return;
		}

		
		// Check if the key is a single English letter (case insensitive)
		if (/^[a-zA-Z]$/.test(key)) {
			// Run function to update text based on the letter typed
			updateText(key, false);
			
			// Prevent default so the character does not get added by the browser as well
			e.preventDefault();
		} else {
			// For all other characters/keys do not do anything
			e.preventDefault();
		}
	};

	// Functionality to actually update the text displayed in the entry field
	const updateText = (letter:string, buttonPress:boolean) => {
		// Get the selection range - relevant if the cursor is manually clicked into the field, not at the end
		setSelection();

		// Insert letter at cursor position
		const newValue = text.slice(0, start) + String(letter).toUpperCase() + text.slice(end);
		setText(newValue);

		// Set caret just after inserted char
		requestAnimationFrame(() => {
			if (buttonPress === true) {
				cursorAtEnd();
			} else {
				// Otherwise update the caret by one
				input.selectionStart = input.selectionEnd = start + 1;
			}
		});
	}

	// Set the cursor selection of the text field
	const setSelection = () => {
		input = inputRef.current;
		start = input.selectionStart;
		end = input.selectionEnd;
	}

	// Set the cursor caret to be at the very end of the text field
	const cursorAtEnd = () => {
		// If the letter is added from one of the Buttons, move the cursor to the very end
		input.selectionStart = text.length + 1;
		input.selectionEnd = text.length + 1;
	}

	// Does the text field contain any text?
	const textExists = () => {
		return text.length > 0;
	}

	// Handles the dyanmic label message
	const handleMsg = () => {
		let msg = '\u2800';	// Space-preserving invisible char
		if (disableLetters) {
			msg = `Maximum allowed length (${maxLength}) reached`
		} else if (text.length > 0) {
			msg = `[ ${text.length} ]`;
		}

		return msg;
	}

	// Submit button has been clicked
	const doSubmit = () => {
		// Send "text" variable to the API to do backend work, and then return the output from that here

		// The "state" auto function to set the value of submitLabelText variable
		setSubmitLabelText(`"${text}" will be sent to the API`);
	}

	// The Front-End
	return (
		<div style={{ fontFamily: "Arial", textAlign: "center", marginTop: "50px" }}>
			<h2>Letter Input Game</h2>
			<h4>{`Enter at least ${minLen} characters and press Submit`}</h4>

			{/* Top controls */}
			<div style={{ display: "flex", alignItems: "center", marginBottom: "15px" , justifyContent: "center"}}>
				{/* The input field */}
				<input
					ref={inputRef}
					type="text"
					value={text}
					maxLength={maxLength}
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
						marginLeft: "5px"
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
				{letters.map((letter) => (
					<button
						key={letter}
						title={letter===backSpaceIcon ? "Backspace" : ""}
						onClick={() => handleLetterClick(letter)}
						disabled={runDisableLetters(letter)} // disables all relevant Letter buttons when at max length
						style={{
							margin: "3px",
							padding: "10px 15px",
							fontSize: "18px",
							cursor: runDisableLetters(letter) ? "not-allowed" : "pointer",
							opacity: runDisableLetters(letter) ? 0.5 : 1
						}}
					>
						{/* The dynamic Letter text displayed on the button */}
						{letter}	
					</button>
				))}
			</div>

			<div style={{marginTop: "20px", display: "flex", justifyContent: "center"}}>
				<button
					disabled={text.length < minLen}
					onClick={doSubmit}
					style={{
						marginTop: "20px",
						margin: "3px",
						padding: "10px 15px",
						fontSize: "18px",
						width: "200px"			// Half of the above hardcoded max-width
					}}
					title={"Submit"}
				>
					Submit
				</button>
			</div>

			{/* JUST FOR TESTING - Until the API exists etc*/}
			<div 
				style={{marginTop: "20px"}}
			>
				{/* Label contents - set by the "State" declared at the top */}
				{submitLabelText}
			</div>
		</div>
	);
}
