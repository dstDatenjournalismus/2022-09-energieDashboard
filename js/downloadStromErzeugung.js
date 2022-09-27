import fs from "fs";
import * as d3 from "d3";
import _ from "lodash";
import node_fetch from "node-fetch";
import { createObjectCsvWriter } from "csv-writer";
import { symbolSquare } from "d3";

global.fetch = node_fetch;

// Formatting Date functions
const makeDay = (date) => {
  return String(date.getDate()).padStart(2, "0");
};
const makeMonth = (date) => String(date.getMonth() + 1).padStart(2, "0");
const makeYear = (date) => date.getFullYear();

export default async function donwloadStromErzeugung() {
  //   let outDir = process.env.CACHE_DIR + "/international";
  const outDir = "output";

  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir);
  }

  const TODAY = new Date();
  const DAY = makeDay(TODAY);
  const MONTH = makeMonth(TODAY);
  const YEAR = makeYear(TODAY);
  const DATE_FORMATTED = `${YEAR}-${MONTH}-${DAY}`;
  const START_DATE = "2021-01-01";
  const START_DATE_M_ONE = "2020-12-31";

  let filename =
    outDir + "/" + DATE_FORMATTED.toString().replace(/-/g, "_") + ".csv";

  // if file already exists do not request it
  if (fs.existsSync(filename)) {
    console.log(`file for ${DATE_FORMATTED} already exists`);
    return;
  }

  // url for
  // const url = `https://transparency.apg.at/transparency-api/api/v1/Download/AGPT/German/M15/2021-01-01T000000/${DATE_FORMATTED}T000000/AGPT_2020-12-31T22_00_00Z_${DATE_FORMATTED}T22_00_00Z_60M_de_${DATE_FORMATTED}T15_40_08Z.csv`;
  const url = `https://transparency.apg.at/transparency-api/api/v1/Download/AGPT/German/M15/${START_DATE}T000000/${DATE_FORMATTED}T000000/AGPT_${START_DATE_M_ONE}T23_00_00Z_${DATE_FORMATTED}T22_00_00Z_60M_de_${DATE_FORMATTED}T15_40_08Z.csv`;
  console.log(`url`, url);
  // https://transparency.apg.at/transparency-api/api/v1/Download/AGPT/German/M60/2021-01-01T000000/2022-09-20T000000/0dfa0bab-bffe-467e-aa21-211dad325f7b/AGPT_2020-12-31T23_00_00Z_2022-09-19T22_00_00Z_60M_de_2022-09-19T12_37_02Z.csv?

  // Fetch data
  let data;
  try {
    data = await d3.dsv(";", url);
    // add date to each row
    data = data.map((e) => {
      return {
        ...e,
        date: e["Zeit von [CET/CEST]"].slice(0, 10),
      };
    });
  } catch (e) {
    console.log(`error `, e);
  }

  let groupedByDate = _.groupBy(data, (d) => d.date);

  // the keys are the dates
  let keys = Object.keys(groupedByDate);

  let res = keys.map((d) => {
    // d is a single date...

    // valsOneDay is an array of Objects of 15 Minute intervals on that day
    let valsOneDay = groupedByDate[d];

    // get enery-types from the first fifteen minutes object
    let types = Object.keys(valsOneDay[0]);
    let dateObj = types.reduce((acc, curr) => {
      acc[curr] = [];
      return acc;
    }, {});

    // for each timestamp add the values to the dateObj-Object
    valsOneDay.forEach((d, i) => {
      let typesOneTime = Object.keys(d);
      typesOneTime.forEach((t) => {
        let val = d[t];
        dateObj[t][i] = val;
      });
    });

    return dateObj;
  });

  let dates = res
    .map((e) => e.date[0])
    .reduce((acc, curr) => {
      acc[curr] = {};
      return acc;
    }, {});

  res.forEach((d, i) => {
    if (i === res.length - 1) {
    }
    let date = d.date[0];
    let types = Object.keys(d);
    types.forEach((t, j) => {
      if (j == 0 || j == 1 || j === types.length - 1) {
        let val = d[t][0];
        dates[date][t] = val;
      } else {
        let val = d[t].reduce((acc, curr) => {
          curr = parseFloat(curr.replace(",", "."));
          return acc + curr;
        }, 0);
        dates[date][t] = val;
      }
    });
  });

  let final = Object.keys(dates).map((k) => dates[k]);
  let r0 = Object.keys(final[0]).map((k) => {
    return {
      id: k,
      title: k,
    };
  });

  const csvWriter = createObjectCsvWriter({
    path: filename,
    header: r0,
  });

  csvWriter.writeRecords(final).then(() => console.log("data written"));
}

donwloadStromErzeugung();
