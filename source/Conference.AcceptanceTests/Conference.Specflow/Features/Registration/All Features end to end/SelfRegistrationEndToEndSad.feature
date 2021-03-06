﻿Feature: Self Registrant end to end scenario for making a Registration for a Conference (sad path)
	In order to register for a conference
	As an Attendee
	I want to be able to register for the conference, pay for the Registration Order and associate myself with the paid Order automatically

Background: 
	Given the list of the available Order Items for the CQRS summit 2012 conference
	| seat type                        | rate |
	| General admission                | $199 |
	| Pre-con Workshop with Greg Young | $500 |
	| Additional cocktail party		   | $50  |	
	And the selected Order Items
	| seat type                        | quantity |
	| General admission                | 1        |
	| Pre-con Workshop with Greg Young | 1        |
	| Additional cocktail party        | 1        |
	And the Promotional Codes
	| Promotional Code | Discount | Quota     | Scope                     | Cumulative |
	| COPRESENTER      | 10%      | Unlimited | Additional cocktail party | Exclusive  |


Scenario: Partial Promotional Code for none of the selected items
	Given the selected Order Items
	| seat type                        | quantity |
	| Pre-con Workshop with Greg Young | 1        |
	And the total amount should be of $500
	When the Registrant apply the 'VOLUNTEER' Promotional Code
	Then the 'VOLUNTEER' Coupon will not be applied and an error message will inform about the problem
	And the total amount should be of $500


#Initial state	: 3 available
#End state		: 2 waitlisted, 1 reserved
Scenario: All Seat Types are available, one get reserved and two get waitlisted
	Given these Seat Types becomes unavailable before the Registrant make the reservation
	| seat type                        |
	| Pre-con Workshop with Greg Young |
	| Additional cocktail party		   |
	When the Registrant proceed to make the Reservation			
	Then the Registrant is offered to be waitlisted for these Order Items
	| seat type                        | quantity |
	| Pre-con Workshop with Greg Young | 1		  |
	| Additional cocktail party		   | 1		  |
	And These other Order Items get reserved
	| seat type                        | quantity |
	| General admission                | 1		  |
	And the countdown will start for the reserved Order Item


#Initial state	: 1 available, 2 waitlisted and 1a & 1w selected
#End state		: 1 reserved,  1 waitlisted confirmed  
Scenario: 1 order item is available, 2 are waitlisted, 1 available and 1 waitlisted are selected, then 1 get reserved and 1 get waitlisted	
	Given the list of available Order Items selected by the Registrant
	| seat type                        | quantity |
	| General admission                | 1        |
	And the list of these Order Items offered to be waitlisted and selected by the Registrant
	| seat type                        | quantity |
	| Pre-con Workshop with Greg Young | 1        |
	| Additional cocktail party        | 0        |	
	When the Registrant proceed to make the Reservation					
	Then these order itmes get confirmed being waitlisted
	| seat type                        | quantity |
	| Pre-con Workshop with Greg Young | 1        |
	And these other order items get reserved
	| seat type         | quantity |
	| General admission | 1        |	
	And the countdown has decreased within the allowed timeslot for holding the Reservation

  
Scenario: Checkout:Registrant Invalid Details
	Given the Registrant enter these details
	| First name | Last name | email address     |
	| John       | Smith     | johnsmith@invalid |
	And the email address is not valid
	# valid = non-empty, email address is valid as per email conventional verification
	When the Registrant proceed to select a payment option
	Then the invalid field is highlighted with a hint of the error cause
	And the countdown has decreased within the allowed timeslot for holding the Reservation


Scenario: Checkout:Payment with cancellation
	Given the Registrant enter these details
	| First name | Last name | email address         |
	| John       | Smith     | johnsmith@contoso.com |
	And the countdown has decreased within the allowed timeslot for holding the Reservation
	And the Registrant select one of the offered payment options
	When the Registrant decides to cancel the payment
    Then a cancelation message will be shown to the Registrant and will get back to the payment options

	
Scenario: Checkout:Payment and place Order
	Given the Registrant enter these details
	| First name | Last name | email address         |
	| John       | Smith     | johnsmith@contoso.com |
	And the countdown has decreased within the allowed timeslot for holding the Reservation
	And the Registrant select one of the offered payment options
	When the Registrant proceed to confirm the payment
    Then a receipt will be received from the payment provider indicating success with some transaction id
	And a Registration confirmation with the Access code should be displayed
	And an email with the Access Code will be send to the registered email. 


Scenario: Partiall Seats allocation
Given the ConfirmSuccessfulRegistration for the selected Order Items
And the Order Access code is 6789
And I assign the purchased seats to attendees as following
	| First name | Last name | email address         | Seat type                 |
	| John       | Smith     | johnsmith@contoso.com | General admission         |
And leave unassigned these seats
	| First name | Last name | email address | Seat type                 |
	|            |           |               | Additional cocktail party |
Then I should be getting a seat assignment confirmation for the seats
	| First name | Last name | email address         | Seat type                 |
	| John       | Smith     | johnsmith@contoso.com | General admission         |
And the Attendees should get an email informing about the conference and the Seat Type with Seat Access Code
	| Access code | email address         | Seat type                 |
	| 6789-1      | johnsmith@contoso.com | General admission         |


Scenario: Complete Seats allocation
Given the ConfirmSuccessfulRegistration for the selected Order Items
And the Order Access code is 6789
And the Registrant assign the purchased seats to attendees as following
	| First name | Last name | email address         | Seat type                 |
	| John       | Smith     | johnsmith@contoso.com | Additional cocktail party |
Then the Registrant should be get a Seat Assignment confirmation
And the Attendees should get an email informing about the conference and the Seat Type with Seat Access Code
	| Access code | email address         | Seat type                 |
	| 6789-2      | johnsmith@contoso.com | Additional cocktail party |