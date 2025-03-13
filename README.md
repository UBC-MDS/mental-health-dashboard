## Mental Health Dashboard 

## Target Audience
Public health professionals, policymakers, and mental health advocates.

Suicide significantly impacts societies globally, highlighting the critical need for targeted preventive measures. 
This interactive dashboard provides users an intuitive way to explore suicide rate data across various demographics, 
including country, year, age groups, and gender. It enables users to pinpoint high-risk populations and track suicide rate trends over time, 
supporting the development of informed decisions and effective intervention strategies.

## App Description

[Video walk through]()

### Data Sources

Data used in this app is sourced from:
- **Suicide rates by sex and age (IHME, 2019)**: [Suicide rates dataset](https://github.com/owid/owid-datasets/blob/master/datasets/Suicide%20rates%20by%20sex%20and%20age%20(IHME%2C%202019)/Suicide%20rates%20by%20sex%20and%20age%20(IHME%2C%202019).csv)
- **Country coordinates**: [Country coordinates dataset](https://gist.github.com/metal3d/5b925077e66194551df949de64e910f6)

## Running the App

Follow the instructions below to run the app locally:

### Clone the Repository:
```bash
git clone https://github.com/UBC-MDS/mental-health-dashboard
cd mental-health-dashboard
```

### Install Required Packages:

R will prompt you to install any missing packages; please follow the instructions to install them.

Run in R:
```R
source("load_data.R")
```

### Start the App:
```R
shiny::runApp("app.R")
```\

## Team 

Nelli Hovhannisyan

## Contributing
Please see [`CONTRIBUTING.md`](https://github.com/UBC-MDS/mental-health-dashboard/blob/main/CONTRIBUTING) for details on contributing to this project.

## License
This project is licensed under the [MIT license](https://github.com/UBC-MDS/mental-health-dashboard/blob/main/LICENSE).


