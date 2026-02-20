const url = 'https://qmvpvwrsvtayktvxergh.supabase.co/rest/v1/clinics';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtdnB2d3JzdnRheWt0dnhlcmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMzM4NjksImV4cCI6MjA4NjcwOTg2OX0.Z05VLRqBelWBrr7LrU6mdpxx3OmXkeMQIXgLAfn48uk';

fetch(url, {
  headers: {
    'apikey': key,
    'Authorization': 'Bearer ' + key
  }
})
.then(res => res.json())
.then(data => {
  console.log("Response:", JSON.stringify(data, null, 2));
})
.catch(err => console.error(err));
