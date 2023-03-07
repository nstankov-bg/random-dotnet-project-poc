import http from "k6/http";
import { check } from "k6";

// See https://k6.io/docs/using-k6/options
export const options = {
    stages: [
        { duration: "1m", target: 20 },
        { duration: "3m", target: 20 },
        { duration: "1m", target: 0 },
    ],
    thresholds: {
        http_req_failed: ["rate<0.02"], // http errors should be less than 2%
        http_req_duration: ["p(95)<2000"], // 95% requests should be below 2s
    },
    ext: {
        loadimpact: {
            distribution: {
                "amazon:us:ashburn": {
                    loadZone: "amazon:us:ashburn",
                    percent: 100,
                },
            },
        },
    },
};

export default function () {
    const url =
        "https://app-nstankov-bg-random-dotnet-crm-poc-pr-2.cloud.okteto.net/api/weather";
    const response = http.get(url);

    check(response, {
        "status is 200": (r) => r.status === 200,
        "response has data": (r) => r.json().length > 0,
    });
}
