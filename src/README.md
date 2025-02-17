src Directory Overview

GlucoseGenie.xcodeproj/

• Purpose: Contains the Xcode project settings, build configurations, and schemes.

• References:
	
	• iOS-Development-Documentation.pdf (Section on Xcode usage).
	• SoftwareDesignDoc-v1.pdf (Section 2.2, “Technologies Used” mentions Swift & Xcode).


GlucoseGenie/

This folder is the heart of the iOS app, structured according to the Software Design Document (Figure 2.3.1) which references a three-layer approach:

	1. Presentation Layer (Views / ViewModels)
	2. Business Logic Layer (ViewModels / Services)
	3. Data Access Layer (Services interacting with APIs, databases, etc.)

Below are the subfolders in GlucoseGenie/:
1. Models/
- Purpose: Holds data structures and entity definitions that mirror the domain objects described in the Software  Requirements Specification.
- Examples: User.swift, Recipe.swift, MealPlan.swift, GroceryItem.swift.
- Relation to Docs:
	- SoftwareDesignDoc-v1.pdf Section 5.2 (Data Model) lists methods and data entities like Recipe, MealPlan, GroceryList, etc.
	- CustomerRequirements-v1.pdf (Section 3) describes how recipes and meal plans must track nutritional info and ingredients.


2. ViewModels/ (if using MVVM)
- Purpose: Encapsulates business logic and transforms Models for display in the Views.
- Examples: RecipeViewModel.swift (fetches recipes, handles filtering), MealPlannerViewModel.swift (manages weekly plans).
- Relation to Docs:
	- SoftwareDesignDoc-v1.pdf Section 2.3 references a “Business Logic Layer” that processes data from the APIs.
	- IOS-Development-Documentation.pdf highlights the MVVM approach for SwiftUI projects.


4. Views/
- Purpose: Contains all SwiftUI View files that render the user interface.
- Examples: LoginView.swift, RecipeSearchView.swift, MealPlanView.swift.
- Relation to Docs:
	- SoftwareDesignDoc-v1.pdf Section 4 (User Interface) shows wireframes and sequence diagrams (2.4.x) describing how each screen interacts with the system.
	 - CustomerRequirements-v1.pdf Section 2 & 3 detail user flows (searching recipes, saving, meal planning) that are reflected in these screens.


5. Services/
- Purpose:
	- Manages Data Access and Networking (APIs).
	 - Integrates with Amazon Cognito for user authentication and Amazon RDS for storing user data (as described in the SRS and the Design Doc).
- Examples:
	- RecipeAPIClient.swift (calls Edamam Recipe API).
	- MapAPIClient.swift (interacts with chosen Map API).
	- UserAuthService.swift (handles Cognito sign-in, sign-up).
	- DatabaseService.swift (handles saving meal plans, saved recipes, etc. to AWS RDS).
- Relation to Docs:
	- SoftwareDesignDoc-v1.pdf Section 2.3 mentions the “Data Access Layer” for APIs, databases.
	 - SoftwareRequirementsSpec-v3.pdf (Section 3) details functional requirements like REQ2 (fetch recipes) and REQ8 (find grocery stores), which rely on these services.


6. Resources/
- Purpose: Holds non-code assets and resource files.
	- Assets.xcassets for images, icons, color sets.
	 - Localizable.strings for bilingual support (English/Spanish) required by SoftwareRequirementsSpec-v3.pdf (REQ3: toggling Spanish mode).
- Relation to Docs:
	- SoftwareDesignDoc-v1.pdf references UI translations in the sequence diagrams (user toggles language).
	- CustomerRequirements-v1.pdf Section 2 requires Spanish translations for all recipe data and user interface text.

8. SupportingFiles/
- Purpose: Apple’s standard location for app-level config and lifecycle files.
	- AppDelegate.swift, SceneDelegate.swift, Info.plist, etc.
	 - Any custom bridging headers if needed.
- Relation to Docs:
	- IOS-Development-Documentation.pdf discusses where iOS app lifecycle code typically resides.
	- SoftwareDesignDoc-v1.pdf Section 2.2 (Technologies Used) references the iOS environment (iOS 12-17.2, Xcode 15.2).

9. Tests/
Houses all test targets. Per the Software Design Document (sequence diagrams in Section 2.4), we must verify each user flow with both unit and UI tests.
- GlucoseGenieTests/
	- Purpose: Unit tests for Models, ViewModels, and Services.
	- Relation to Docs:
		- SoftwareRequirementsSpec-v3.pdf requires verifying correctness of core features (REQ1–REQ10).
		- ProjectPlan-v3.pdf references test plans and defect reports.
• GlucoseGenieUITests/
	- Purpose: Automated UI tests using XCUITest to validate user flows (login, searching recipes, saving meal plans).
	- Relation to Docs:
		- SoftwareDesignDoc-v1.pdf references the user flows in the sequence diagrams.
		- IOS-Development-Documentation.pdf mentions XCUITest as Apple’s recommended UI testing framework.


Package.swift (Optional)
- Purpose: If using Swift Package Manager for external dependencies (e.g., an HTTP library, AWS SDK, etc.), they will be done here.
- Relation to Docs:
	- IOS-Development-Documentation.pdf states SwiftPM can be used for managing iOS dependencies.
	 - SoftwareDesignDoc-v1.pdf mentions third-party APIs (Edamam, Map API) which might be integrated via SwiftPM if official packages exist.
