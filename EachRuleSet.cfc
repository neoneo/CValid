/*
   Copyright 2012 Neo Neo

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/**
 * EachRuleSet is a RuleSet that tests its rules against all elements in a given set.
 **/
component EachRuleSet extends="RuleSet" {

	public void function init(boolean merge = false, string index = "") {
		variables.merge = arguments.merge;
		variables.index = arguments.index;
	}

	public void function setField(required string fieldName) {
		variables.fieldName = arguments.fieldName;
	}

	public array function validate(required struct data) {

		var messages = [];
		var set = toArray(Evaluate("arguments.data.#variables.fieldName#"));
		var passed = true;

		// create a copy of the data that we can modify
		var transport = StructCopy(arguments.data);
		var i = 1;
		for (var element in set) {
			// replace the field with the element
			"transport.#variables.fieldName#" = element;
			if (Len(variables.index) > 0) {
				transport[variables.index] = i; // make the index available to the rules
			}
			// call the super method, so the element is tested against the rules
			var result = super.validate(transport);
			// if a ValidRule is tested, and passed, the value may have been converted
			// write the value back to the set; if the set was already an array before it was passed in here, the converted value goes back to the caller
			set[i] = Evaluate("transport.#variables.fieldName#");
			if (variables.merge) {
				// only include distinct messages
				for (var message in result) {
					if (ArrayFind(messages, message) == 0) {
						ArrayAppend(messages, message);
					}
				}
				passed = ArrayIsEmpty(messages);
			} else {
				// put the results on the messages array unmodified
				// so the result is an array within an array
				ArrayAppend(messages, result);
				// now that the messages array is no longer empty, we keep a separate boolean to track if all rules have passed
				passed = passed && ArrayIsEmpty(result);
			}
			i++;
		}
		if (passed && !variables.merge) {
			// messages is an array of empty arrays, so we return an empty array to signify all rules have passed
			ArrayClear(messages);
		}

		return messages;
	}


	private array function toArray(required any value) {

		if (IsArray(arguments.value)) {
			return arguments.value;
		} else if (IsSimpleValue(arguments.value)) {
			return ListToArray(arguments.value);
		} else {
			Throw("Cannot convert value to array");
		}

	}

}