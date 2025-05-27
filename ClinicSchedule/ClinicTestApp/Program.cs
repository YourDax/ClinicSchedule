using System;
using System.Collections.Generic;
using System.Runtime.Intrinsics.Arm;
using ClinicScheduleBusinessLogic.BusinessLogic;
using ClinicScheduleContracts.BindingModels;
using ClinicScheduleContracts.BusinesLogicContracts;
using ClinicScheduleContracts.BusinessLogicContracts;
using ClinicScheduleContracts.StorageContracts;
using ClinicScheduleDatabaseImplement.Implements;
using ClinicScheduleModels.Enums;
using ClinicScheduleModels.Models;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace ClinicScheduleConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            // Настройка DI и логгера (пример)
            var services = new ServiceCollection();
            services.AddLogging(config => config.AddConsole());
            // Здесь нужно добавить регистрацию всех логик и хранилищ
            services.AddScoped<IDoctorLogic, DoctorLogic>();
            services.AddScoped<INurseLogic, NurseLogic>();
            services.AddScoped<IDepartmentLogic, DepartmentLogic>();
            services.AddScoped<IShiftLogic, ShiftLogic>();
            services.AddScoped<IScheduleLogic, ScheduleLogic>();

            services.AddScoped<IDoctorStorage, DoctorStorage>();
            services.AddScoped<INurseStorage, NurseStorage>();
            services.AddScoped<IDepartmentStorage, DepartmentStorage>();
            services.AddScoped<IShiftStorage, ShiftStorage>();
            services.AddScoped<IScheduleStorage, ScheduleStorage>();


            var serviceProvider = services.BuildServiceProvider();

            var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
            // Хранилища
            
            

            var doctorLogic = serviceProvider.GetRequiredService<IDoctorLogic>();
            var nurseLogic = serviceProvider.GetRequiredService<INurseLogic>();
            var departmentLogic = serviceProvider.GetRequiredService<IDepartmentLogic>();
            var shiftLogic = serviceProvider.GetRequiredService<IShiftLogic>();
            var scheduleLogic = serviceProvider.GetRequiredService<IScheduleLogic>();

            // Создаем 10 департаментов
            for (int i = 1; i <= 10; i++)
            {
                var depName = $"Департамент #{i}";
                if (departmentLogic.ReadList(new() { name = depName })?.Count == 0)
                {
                    departmentLogic.Create(new DepartmentBindingModel { name = depName });
                    Console.WriteLine($"Создан департамент: {depName}");
                }
                else
                {
                    Console.WriteLine($"Департамент {depName} уже существует");
                }
            }

            var departments = departmentLogic.ReadList(null);
            /*var doctorLogin = $"doc10_1";
            if (doctorLogic.ReadList(new() { login = doctorLogin })?.Count == 0)
            {
                var doctorFullName = $"Доктор деп #10";
                doctorLogic.Create(new DoctorBindingModel
                {
                    fullname = doctorFullName,
                    login = doctorLogin,
                    password = "pass",
                    birthdate = new DateTime(1980, 1, 1),
                    phoneNumber = "1234567890",
                    specialization = "Терапия",
                    experienceYears = 5,
                    departmentId = 10
                });
                Console.WriteLine($"Создан доктор: {doctorFullName}");
            }*/

            // Создаем 10 докторов и 10 медсестер для каждого департамента
            foreach (var dep in departments!)
            {
                for (int i = 1; i <= 10; i++)
                {
                    var doctorLogin = $"doc{dep.id}_{i}";
                    if (doctorLogic.ReadList(new() { login = doctorLogin })?.Count == 0)
                    {
                        var doctorFullName = $"Доктор {dep.name} #{i}";
                        doctorLogic.Create(new DoctorBindingModel
                        {
                            fullname = doctorFullName,
                            login = doctorLogin,
                            password = "pass",
                            birthdate = new DateTime(1980 + i, 1, 1),
                            phoneNumber = "1234567890",
                            specialization = "Терапия",
                            experienceYears = 5 + i,
                            departmentId = dep.id
                        });
                        Console.WriteLine($"Создан доктор: {doctorFullName}");
                    }
                    else
                    {
                        Console.WriteLine($"Доктор с логином {doctorLogin} уже существует");
                    }

                    var nurseLogin = $"nurse{dep.id}_{i}";
                    if (nurseLogic.ReadList(new() { login = nurseLogin })?.Count == 0)
                    {
                        var nurseFullName = $"Медсестра {dep.name} #{i}";
                        nurseLogic.Create(new NurseBindingModel
                        {
                            fullname = nurseFullName,
                            login = nurseLogin,
                            password = "pass",
                            birthdate = new DateTime(1990 + i, 1, 1),
                            phoneNumber = "0987654321",
                            specialization = "Общая практика",
                            experienceYears = 3 + i,
                            departmentId = dep.id
                        });
                        Console.WriteLine($"Создана медсестра: {nurseFullName}");
                    }
                    else
                    {
                        Console.WriteLine($"Медсестра с логином {nurseLogin} уже существует");
                    }
                }
            }


            // Создаем 2 смены для каждого департамента (8:00-16:00 и 16:00-24:00)
            foreach (var dep in departments)
            {
                var today = DateTime.Today;

                var shift1Start = today.AddHours(8);
                var shift1End = today.AddHours(16);

                if (shiftLogic.ReadList(new() { departmentId = dep.id })?.FindAll(s => s.startTime == shift1Start && s.endTime == shift1End).Count == 0)
                {
                    shiftLogic.Create(new ShiftBindingModel
                    {
                        startTime = shift1Start,
                        endTime = shift1End,
                        requiredDoctors = 2,
                        requiredNurses = 1,
                        departmentId = dep.id
                    });
                    Console.WriteLine($"Создана смена 08:00-16:00 для {dep.name}");
                }
                else
                {
                    Console.WriteLine($"Смена 08:00-16:00 для {dep.name} уже существует");
                }

                var shift2Start = today.AddHours(16);
                var shift2End = today.AddHours(24);

                if (shiftLogic.ReadList(new() { departmentId = dep.id })?.FindAll(s => s.startTime == shift2Start && s.endTime == shift2End).Count == 0)
                {
                    shiftLogic.Create(new ShiftBindingModel
                    {
                        startTime = shift2Start,
                        endTime = shift2End,
                        requiredDoctors = 2,
                        requiredNurses = 1,
                        departmentId = dep.id
                    });
                    Console.WriteLine($"Создана смена 16:00-24:00 для {dep.name}");
                }
                else
                {
                    Console.WriteLine($"Смена 16:00-24:00 для {dep.name} уже существует");
                }
            }

            // Ручное создание расписания для первого департамента на сегодня
            var firstDep = departments[0];
            var scheduleDate = DateTime.Today;

            // Получаем смены для департамента — важно, чтобы в model.shifts был непустой список
            var shiftsForFirstDep = shiftLogic.ReadList(new() { departmentId = firstDep.id })!;

            var manualSchedule = new ScheduleBindingModel
            {
                date = scheduleDate,
                departmentId = firstDep.id,
                shifts = shiftsForFirstDep.Cast<IShiftModel>().ToList(),
                assignments = new List<ScheduleAssignmentBindingModel>()
            };


            var createdSchedule = scheduleLogic.Create(manualSchedule);

            Console.WriteLine(createdSchedule
                ? $"Ручное расписание для {firstDep.name} на {scheduleDate:dd.MM.yyyy} создано"
                : "Ошибка создания расписания");


            // Автоматическое создание расписаний для второго департамента на следующие 3 дня
            var secondDep = departments[1];
            var autoScheduleDates = new List<DateTime>
            {
                DateTime.Today.AddDays(1),
                DateTime.Today.AddDays(2),
                DateTime.Today.AddDays(3)
            };

            var generated = scheduleLogic.GenerateSchedule(secondDep.id, autoScheduleDates);
            Console.WriteLine(generated ? $"Автоматическое расписание для {secondDep.name} создано на даты {string.Join(", ", autoScheduleDates)}" : "Ошибка генерации расписания");

            Console.WriteLine("Тестирование завершено.");
        }
    }
}
