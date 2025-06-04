using ClinicScheduleBusinessLogic.BusinessLogic;
using ClinicScheduleBusinessLogic.Logic;
using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.BusinessLogicContracts;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleDatabaseImplement.Implements;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Logging.SetMinimumLevel(LogLevel.Trace);

// Подключение хранилищ
builder.Services.AddTransient<IDepartmentStorage, DepartmentStorage>();
builder.Services.AddTransient<IDoctorStorage, DoctorStorage>();
builder.Services.AddTransient<INurseStorage, NurseStorage>();
builder.Services.AddTransient<IUserStorage, UserStorage>();
builder.Services.AddTransient<IShiftStorage, ShiftStorage>();
builder.Services.AddTransient<IScheduleStorage, ScheduleStorage>();
builder.Services.AddTransient<IScheduleAssignmentStorage, ScheduleAssignmentStorage>();


// Подключение бизнес-логики
builder.Services.AddTransient<IDepartmentLogic, DepartmentLogic>();
builder.Services.AddTransient<IDoctorLogic, DoctorLogic>();
builder.Services.AddTransient<INurseLogic, NurseLogic>();
builder.Services.AddTransient<IUserLogic, UserLogic>();
builder.Services.AddTransient<IShiftLogic, ShiftLogic>();
builder.Services.AddTransient<IScheduleLogic, ScheduleLogic>();
builder.Services.AddTransient<IScheduleAssignmentLogic, ScheduleAssignmentLogic>();

builder.Services.AddControllers();

// Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "ClinicScheduleRestApi",
        Version = "v1"
    });
});

var app = builder.Build();

// Swagger UI только в dev-среде
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "ClinicScheduleRestApi v1"));
}

//app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
