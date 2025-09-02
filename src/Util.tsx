import React from 'react';

// Use this file for common functions

// Force HTML linebreaks in a string
export function addLineBreak (str: string) : React.JSX.Element[] {
	return str.split('\n').map((subStr, index) => (
		<React.Fragment key={index}>
			{subStr}
			<br />
		</React.Fragment>
	));
};

const Util = {
	addLineBreak
	// other utility functions here to be exported ...
}

export default Util;