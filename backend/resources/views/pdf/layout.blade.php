<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{{ $form->type }} - Form {{ $form->id }}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .section {
            margin-bottom: 20px;
        }
        .section-title {
            background-color: #f0f0f0;
            padding: 8px;
            font-weight: bold;
            border-left: 4px solid #333;
        }
        .field-row {
            margin-bottom: 8px;
            padding: 5px 0;
            border-bottom: 1px dashed #ddd;
        }
        .field-label {
            font-weight: bold;
            display: inline-block;
            width: 25%;
        }
        .field-value {
            display: inline-block;
            width: 70%;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            font-size: 12px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{ ucfirst(str_replace('_', ' ', $form->type)) }} Form</h1>
        <p>Form ID: {{ $form->id }} | Date: {{ $form->created_at->format('d M Y H:i') }} | Status: {{ strtoupper($form->status) }}</p>
        @if(isset($patient) && $patient)
        <p>Patient: {{ $patient->name ?? 'N/A' }} | Age: {{ $patient->age ?? 'N/A' }} | Gender: {{ $patient->gender ?? 'N/A' }}</p>
        @endif
        @if(isset($user) && $user)
        <p>Created By: {{ $user->name ?? 'N/A' }}</p>
        @endif
    </div>
    
    {{ $slot }}
    
    <div class="footer">
        <p>Generated on {{ now()->format('d M Y H:i:s') }}</p>
    </div>
</body>
</html>